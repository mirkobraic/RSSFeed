//
//  RSSParser.swift
//  RSSFeed
//
//  Created by Mirko Braic on 27.12.2023..
//

import Foundation

class RSSParser: NSObject, XMLParserDelegate {
    var xmlParser: XMLParser!

    var currentElement = ""
    var foundCharacters = ""
    var currentData = [String: String]()
    var parsedData = [[String: String]]()
    var isHeader = true

    func startParsing(from url: URL, completion: (Bool) -> Void) {
        let parser = XMLParser(contentsOf: url)
        parser?.delegate = self

        if let flag = parser?.parse() {
            parsedData.append(currentData)
            completion(flag)
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
    }
}
