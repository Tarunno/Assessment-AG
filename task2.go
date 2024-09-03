package main

import (
    "fmt"
    "net"
    "sync"
)

func handleConnection(wg *sync.WaitGroup, id int) {
    defer wg.Done()
    
    conn, err := net.Dial("tcp", "localhost:8080")
    if err != nil {
        fmt.Println("Error connecting:", err)
        return
    }
    defer conn.Close()

    message := fmt.Sprintf("Hello from client %d\n", id)
    fmt.Fprintf(conn, message)

    response := make([]byte, 1024)
    _, err = conn.Read(response)
    if err != nil {
        fmt.Println("Error reading:", err)
        return
    }

    fmt.Printf("Response from server: %s", string(response))
}

func main() {
    var wg sync.WaitGroup
    clientCount := 10

    for i := 0; i < clientCount; i++ {
        wg.Add(1)
        go handleConnection(&wg, i)
    }

    wg.Wait()
}
