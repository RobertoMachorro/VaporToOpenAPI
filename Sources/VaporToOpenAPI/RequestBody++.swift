import Foundation
import SwiftOpenAPI

func request(
	body: OpenAPIValue?,
	description: String?,
	required: Bool?,
	types: [MediaType],
	schemas: inout [String: ReferenceOr<SchemaObject>],
	examples: inout [String: ReferenceOr<ExampleObject>]
) -> ReferenceOr<RequestBodyObject>? {
	guard
		let bodyObject = try? body?.mediaTypeObject(schemas: &schemas, examples: &examples)
	else {
		return nil
	}
	return .value(
		RequestBodyObject(
			description: description,
			content: ContentObject(
				dictionaryElements: (types.nilIfEmpty ?? [.application(.json)]).map { ($0, bodyObject) }
			),
			required: required
		)
	)
}
