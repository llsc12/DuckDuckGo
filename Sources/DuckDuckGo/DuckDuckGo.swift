//
//  DuckDuckGo.swift
//  DuckDuckGo
//
//  Created by Lakhan Lothiyi on 28/11/2022.
//

#if os(macOS)
import AppKit
#endif
#if os(iOS)
import UIKit
#endif
#if os(watchOS)

#endif
import CoreFoundation
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
            guard let urlStr = try? result.getElementsByClass("result__a").first()?.attr("href") else { continue }
            guard let url = URL(string: urlStr) else { continue }
            guard let iconImgSrcStr = try? result.getElementsByClass("result__icon").first()?.children().first()?.children().first()?.attr("src") else { continue }
            guard let icon = URL(string: "https:\(iconImgSrcStr)") else { continue }
            guard let snippet = try? result.getElementsByClass("result__snippet").text() else { continue }
//            guard let snippet = snippetHtmlData.html2String else { continue }
            
            let object = Result(title: title, url: url, icon: icon, snippet: snippet)
            resultsObject.results.append(object)
        }
        
        return resultsObject
    }
    
    public struct SearchResults {
        public let query: String
        public let url: URL
        public var results: [DuckDuckGo.Result]
    }
    
    public struct Result: Identifiable {
        public var id: URL { url }
        public let title: String
        public let url: URL
        public let icon: URL
        public let snippet: String
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

//fileprivate extension Data {
//    var html2String: String? {
//        #if !os(watchOS)
//        let str = try? NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
//        return str?.string
//        #endif
//        #if os(watchOS)
//            return nil
//        #endif
//    }
//}
