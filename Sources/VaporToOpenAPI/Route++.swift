//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Vapor
import Swiftgger

extension Route {
	@discardableResult
	public func openAPI(
		summary: String = "",
		description: String = "",
    response: (any WithExample.Type)? = nil,
    content: (any WithExample.Type)? = nil,
    query: any WithExample.Type...,
    headers: any HeadersType.Type...,
		responses: [APIResponse] = []
	) -> Route {
		set(\.contentType, to: content)
			.set(\.queryType, to: query)
			.set(\.headersType, to: headers)
			.set(\.summary, to: summary)
			.set(\.responseCustomType, to: response)
			.description(description)
	}
}

extension Route {
	
	public var summary: String {
		values.summary ?? ""
	}
	
	@discardableResult
	public func summary(_ value: String) -> Route {
		set(\.summary, to: value)
	}
	
	public var responses: [APIResponse] {
		values.responses ?? []
	}
    
	var _excludeFromOpenAPI: Bool {
    values._excludeFromOpenAPI ?? false
	}
    
	public func excludeFromOpenAPI() -> Route {
    set(\._excludeFromOpenAPI, to: true)
	}
    
	public var openAPIRequestType: Decodable.Type? {
		contentType ?? (requestType == Request.self ? nil : requestType as? Decodable.Type)
	}
	
	public var openAPIResponseType: Any.Type {
		let type = responseCustomType ?? (responseType as? EventLoopType.Type)?.valueType ?? responseType
		if type == View.self {
			return HTML.self
		} else if type == Response.self {
			return Unknown.self
		} else {
			return type
		}
	}
	
    var openAPIObjectTypes: [any OpenAPIObject.Type] {
        var result: [any OpenAPIObject.Type] = []
        if let openAPIRequestType,
           let objectType = openAPIRequestType as? any OpenAPIObjectConvertable.Type {
            result.append(objectType.openAPIType)
        }
        if let objectType = openAPIResponseType as? any OpenAPIObjectConvertable.Type {
            result.append(objectType.openAPIType)
        }
        return result
    }
    
	public var contentType: (any WithExample.Type)? {
		values.contentType
	}
	
	public var responseCustomType: (any WithExample.Type)? {
		values.responseCustomType
	}
	
	public var queryType: [any WithExample.Type] {
		values.queryType ?? []
	}
	
	public var headersType: [any HeadersType.Type] {
		values.headersType ?? []
	}
}

private struct HTML: OpenAPIContent, CustomStringConvertible, APIPrimitiveType, WithExample {
    
	static var apiDataType: APIDataType { .string }
	static var defaultContentType: HTTPMediaType { .html }
	let description = "<html>HTML text</html>"
	
	static var example: HTML { HTML() }
	
	init() {}
	
	init(from decoder: Decoder) throws {
		_ = try String(from: decoder)
	}
	
	func encode(to encoder: Encoder) throws {
		try description.encode(to: encoder)
	}
}

private struct Unknown: OpenAPIContent, WithExample, APIPrimitiveType {
    
	static var apiDataType: APIDataType { .string }
	static var example: Unknown { Unknown() }
	public static var defaultContentType: HTTPMediaType { .any }
}
