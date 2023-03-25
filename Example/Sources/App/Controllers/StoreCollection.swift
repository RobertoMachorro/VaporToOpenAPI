import Foundation
import Vapor
import VaporToOpenAPI

public struct StoreController: RouteCollection {

	public func boot(routes: RoutesBuilder) throws {
		routes
			.group("store") { routes in
				routes.get("inventory") { _ in
					["Key": 100]
				}
				.openAPI(
					summary: "Returns pet inventories by status",
					description: "Returns a map of status codes to quantities",
					response: ["Cat": Int32.example],
					auth: .petstoreApiKey
				)

				routes.group("order") { routes in
					routes.post { _ in
						Order.example
					}
					.openAPI(
						summary: "Place an order for a pet",
						description: "Place a new order in the store",
						body: Order.example,
						bodyType: .application(.json), .application(.xml), .application(.urlEncoded),
						response: Order.example,
						errorDescriptions: [
							405: "Invalid input",
						]
					)

					routes.group(":orderId") { routes in
						routes.get { _ in
							Order.example
						}
						.openAPI(
							summary: "Find purchase order by ID",
							description: "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.",
							response: Order.example,
							responseType: .application(.xml), .application(.json),
							errorDescriptions: [
								400: "Invalid ID supplied",
								404: "Order not found",
							]
						)

						routes.delete { _ in
							"Success delete"
						}
						.openAPI(
							summary: "Delete purchase order by ID",
							description: "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors",
							errorDescriptions: [
								400: "Invalid ID supplied",
								404: "Order not found",
							]
						)
					}
				}
			}
	}
}