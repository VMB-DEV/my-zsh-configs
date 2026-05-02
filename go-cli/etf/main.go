package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strconv"
	"strings"
	"sync"
	"text/tabwriter"
	"time"
)

type holding struct {
	isin     string
	name     string
	quantity int
}

type quote struct {
	h     holding
	price float64
	err   error
}

var holdings = []holding{
	{"FR0011871128", "SP500", 3},
	{"FR0013412020", "Emerging", 4},
	{"FR0013412038", "Europe", 6},
}

var (
	symbolRe = regexp.MustCompile(`/cours/[^/]+/`)
	priceRe  = regexp.MustCompile(`c-instrument--last[^>]*>([^<]+)<`)
)

var client = &http.Client{Timeout: 10 * time.Second}

func httpGet(url string) (string, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", err
	}
	req.Header.Set("User-Agent", "Mozilla/5.0")
	resp, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer func() { _ = resp.Body.Close() }()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	return string(body), nil
}

func parsePrice(raw string) (float64, error) {
	var b strings.Builder
	for _, r := range raw {
		if (r >= '0' && r <= '9') || r == ',' || r == '.' {
			b.WriteRune(r)
		}
	}
	cleaned := strings.ReplaceAll(b.String(), ",", ".")
	return strconv.ParseFloat(cleaned, 64)
}

func fetchQuote(h holding) quote {
	body, err := httpGet("https://www.boursorama.com/recherche/ajax?query=" + h.isin)
	if err != nil {
		return quote{h: h, err: err}
	}
	sym := symbolRe.FindString(body)
	if sym == "" {
		return quote{h: h, err: fmt.Errorf("symbol not found")}
	}
	body, err = httpGet("https://www.boursorama.com/bourse/trackers" + sym)
	if err != nil {
		return quote{h: h, err: err}
	}
	m := priceRe.FindStringSubmatch(body)
	if m == nil {
		return quote{h: h, err: fmt.Errorf("price not found")}
	}
	price, err := parsePrice(m[1])
	if err != nil {
		return quote{h: h, err: err}
	}
	return quote{h: h, price: price}
}

func fmtEUR(v float64) string {
	return strings.Replace(fmt.Sprintf("%.2f", v), ".", ",", 1) + " €"
}

func main() {
	results := make([]quote, len(holdings))
	var wg sync.WaitGroup
	for i, h := range holdings {
		wg.Add(1)
		go func(i int, h holding) {
			defer wg.Done()
			results[i] = fetchQuote(h)
		}(i, h)
	}
	wg.Wait()

	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	total := 0.0
	hasErr := false
	for _, r := range results {
		if r.err != nil {
			fmt.Fprintf(w, "%s\t%s\tERROR: %v\n", r.h.name, r.h.isin, r.err)
			hasErr = true
			continue
		}
		line := r.price * float64(r.h.quantity)
		total += line
		fmt.Fprintf(w, "%s\t%s\t%s\t× %d\t= %s\n",
			r.h.isin,
			r.h.name,
			fmtEUR(r.price), r.h.quantity, fmtEUR(line))
	}
	fmt.Fprintf(w, "Total\t\t\t\t= %s\n", fmtEUR(total))
	_ = w.Flush()

	if hasErr {
		os.Exit(1)
	}
}
