//
//  DuckDuckGo.swift
//  DuckDuckGo
//
//  Created by Lakhan Lothiyi on 28/11/2022.
//

import Foundation
import SwiftSoup

public final class DuckDuckGo {
    
    internal static func searchUrlBuilder(query: String) -> URL {
        let baseStr = "https://html.duckduckgo.com/html/"
        var comp = URLComponents(string: baseStr)!
        comp.queryItems = [URLQueryItem(name: "q", value: query)]
        return comp.url!
    }
    
    public static func getSearchCompletions(_ q: String) async throws {
        
    }
    
    internal static func isValidResultElement(_ elem: Element) -> Bool {
        elem.hasClass("web-result")
    }
    
    public static func search(_ q: String) async throws -> DuckDuckGo.SearchResults {
        
        // MARK: - Craft url and request
        guard let query = q.queryFormatted else { throw self.Errors.disallowedQuery }
        let url = self.searchUrlBuilder(query: query)
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        // MARK: - Get data from request and make it html
        let (data, _) = try await URLSession.shared.data(for: req)
        guard let dataHtml = String(data: data, encoding: .utf8) else { throw self.Errors.failedToStringify }
        let html = try SwiftSoup.parse(dataHtml, url.absoluteString)
        
        // MARK: - Parse html into objects
        guard let body = html.body() else { throw self.Errors.noBody}
        guard let resultsHtml = try? body.getElementsByClass("results").first() else { throw self.Errors.noBody }
        let resultsHtmlArray = resultsHtml.children().filter { element in
            self.isValidResultElement(element)
        }
        
        var resultsObject = SearchResults(query: q, url: url, results: [])
        
        for result in resultsHtmlArray {
            guard let title = try? result.getElementsByClass("result__title").first()?.text().removingPercentEncoding else { continue }
            guard let urlStr = try? result.getElementsByClass("result__url").first()?.attr("href") else { continue }
            guard let url = URL(string: urlStr) else { continue }
            guard let iconImgSrcStr = try? result.getElementsByClass("result__icon").first()?.children().first()?.children().first()?.attr("src") else { continue }
            guard let icon = URL(string: "https:\(iconImgSrcStr)") else { continue }
            guard let snippetHtmlData = try? result.getElementsByClass("result__snippet").html().data(using: .utf8) else { continue }
            guard let snippet = snippetHtmlData.html2String else { continue }
            
            let object = Result(title: title, url: url, icon: icon, snippet: snippet)
            resultsObject.results.append(object)
        }
        
        return resultsObject
    }
    
    public struct SearchResults {
        let query: String
        let url: URL
        var results: [DuckDuckGo.Result]
    }
    
    public struct Result: Identifiable {
        public var id: URL { url }
        let title: String
        let url: URL
        let icon: URL
        let snippet: String
    }
    
    public enum Errors: Error {
        case disallowedQuery
        case failedToStringify
        case noBody
    }
}

fileprivate extension String {
    var queryFormatted: String? {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}

fileprivate extension Data {
    var html2String: String? {
        let str = NSAttributedString(html: self, documentAttributes: nil)
        return str?.string
    }
}
