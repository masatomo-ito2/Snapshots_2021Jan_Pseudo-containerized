/*
 * Written by Masa (masa@hashicorp.com) for snapshots
 */

package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"
)

type Resp struct {
	Color    string
	Addr     string
	Mode     string
	TaskId   string
	Pid      string
	PublicIP string
	Version  string
}

func returnWebPage(w http.ResponseWriter, r *http.Request) {

	tpl := `
<!DOCTYPE html>
<html>
<body>
<h1 style="color:{{.Color}};">Welcome to HashiCorp Snapshots app version <u>{{.Version}}</u>!</h1>
<h1 style="color:{{.Color}};">Hey, I am <u>{{.Mode}}</u> app (Task ID=<u>{{.TaskId}}</u>) running at <u>{{.Addr}}</u></h1>
<h1 style="color:{{.Color}};">My public IP is <u>{{.PublicIP}}</u>.</h1>
<h1 style="color:{{.Color}};">My process ID is <u>{{.Pid}}</u>. Feel free to kill me, I come back anyway.</h1>
</body>
</html>`

	// debug
	fmt.Printf("Path: %s\n", r.URL.Path)
	fmt.Printf("rawQuery: %s\n", r.URL.RawQuery)

	// obtain upstream URL from environment variable
	url := os.Getenv("UPSTREAM_URL")

	// construqt http get request
	request, err := http.NewRequest("GET", url+r.URL.Path, nil)
	if err != nil {
		fmt.Fprint(w, "<html><body><h1>Query generation failed</h1></body></html>")
		log.Fatal(err)
		return
	}

	// set raw query parameters
	request.URL.RawQuery = r.URL.RawQuery

	// set time for 3 seconds
	timeout := time.Duration(3 * time.Second)
	client := &http.Client{
		Timeout: timeout,
	}

	// send a GET request
	resp, err := client.Do(request)
	if err != nil {
		fmt.Fprint(w, "<html><body><h1>Connection blocked</h1></body></html>")
		log.Fatal(err)
		return
	}
	defer resp.Body.Close()

	var attr Resp

	// --- Debug ---
	/*
		fmt.Printf("=== Status ===\n")
		fmt.Printf("%s %s\n", resp.Proto, resp.Status)
		fmt.Printf("=== Header ===\n")
		for k, v := range resp.Header {
			fmt.Printf("%s: %s\n", k, v)
		}
		fmt.Printf("=== Body ===\n")
	*/
	// --------------

	err = json.NewDecoder(resp.Body).Decode(&attr)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(attr.TaskId)

	var t = template.Must(template.New("webpage").Parse(tpl))
	t.Execute(w, attr)
}

func main() {
	port := os.Getenv("PORT")
	mux := http.NewServeMux()
	server := &http.Server{
		Addr:    fmt.Sprintf("0.0.0.0:%v", port),
		Handler: mux,
	}
	mux.HandleFunc("/", returnWebPage)
	server.ListenAndServe()
}
