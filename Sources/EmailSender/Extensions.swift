//
//  Extensions.swift
//  AWSExtras
//
//  Created by Mathew Gacy on 12/8/23.
//

import AWSSES
import Foundation

extension SESClientTypes.Body {
    /// Creates an SES body.
    ///
    /// - Parameter body: The email body.
    init(_ body: Body) {
        var html: SESClientTypes.Content?
        var text: SESClientTypes.Content?

        switch body {
        case .text(let string):
            text = .init(data: string)
        case .html(let htmlContent):
            html = .init(data: htmlContent)
        case let .combined(textContent, htmlContent):
            text = .init(data: textContent)
            html = .init(data: htmlContent)
        }

        self.init(html: html, text: text)
    }
}

