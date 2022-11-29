# DuckDuckGo

Swift package for getting search results from DuckDuckGo.

## Usage

### Searching
```swift
let search = try await DuckDuckGo.search("Hacking with Swift")

// Returns ->
//DuckDuckGo.SearchResults(
//    query: "Hacking with Swift",
//    url: https://html.duckduckgo.com/html/?q=Hacking%2520with%2520Swift,
//    results: [
//        DuckDuckGo.Result(
//            title: "Hacking with Swift - learn to code iPhone and iPad apps with free Swift ...",
//            url: https://duckduckgo.com/l/?uddg=https%3A%2F%2Fwww.hackingwithswift.com%2F&rut=5a468c4231c9f99d84aa6d55a952aa2fdd7984dfe56cd4a8fbe6120219f125d9,
//            icon: https://external-content.duckduckgo.com/ip3/www.hackingwithswift.com.ico,
//            snippet: "Hacking with Swift builds on extensive research into learning and memory, to help you learn app development faster and more thoroughly. Spaced Repetition Our courses cover the important topics of app development, and repeat them at spaced intervals to help them sink into your long-term memory. Interactive Review"),
//        ...
//    ]
//)
```

### Completions
```swift
