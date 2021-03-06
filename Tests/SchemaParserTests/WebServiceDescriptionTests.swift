import XCTest

@testable import Lark
@testable import SchemaParser

class WebServiceDescriptionTests: XCTestCase {
    func deserialize(_ input: String) throws -> WebServiceDescription {
        let url = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Inputs")
            .appendingPathComponent(input)
        return try parseWebServiceDescription(contentsOf: url)
    }

    func qname(_ localName: String) -> QualifiedName {
        return QualifiedName(uri: "http://tempuri.org/", localName: localName)
    }

    func testNumberConversion() throws {
        let webService = try deserialize("numberconversion.wsdl")
        XCTAssertEqual(webService.bindings.count, 2)
        XCTAssertEqual(webService.bindings.first?.name, qname("NumberConversionSoapBinding"))
        XCTAssertEqual(webService.bindings.map({ $0.operations }).count, 2)

        XCTAssertEqual(webService.messages.count, 4)
        XCTAssertEqual(webService.messages.first?.name, qname("NumberToWordsSoapRequest"))
        XCTAssertEqual(webService.messages.flatMap({ $0.parts }).count, 4)

        XCTAssertEqual(webService.portTypes.count, 1)
        XCTAssertEqual(webService.portTypes.first?.name, qname("NumberConversionSoapType"))
        XCTAssertEqual(webService.portTypes.flatMap({ $0.operations }).count, 2)

        XCTAssertEqual(webService.schema.count, 4)
        XCTAssertEqual(webService.schema.first?.element?.name, qname("NumberToWords"))

        XCTAssertEqual(webService.services.count, 1)
        XCTAssertEqual(webService.services.first?.name, qname("NumberConversion"))
        XCTAssertEqual(webService.services.flatMap({ $0.ports }).count, 2)
    }

    func testImport() throws {
        let webService = try deserialize("import.wsdl")
        XCTAssertEqual(webService.schema.count, 3)
    }

    func testFileNotFound() throws {
        do {
            _ = try deserialize("file_not_found.wsdl")
        } catch let error as NSError where error.code == 260 {
        }
    }

    func testBrokenImport() throws {
        do {
            _ = try deserialize("broken_import.wsdl")
            XCTFail("Parsing WSDL with broken import should fail")
        } catch let error as NSError where error.code == 260 {
        } catch let error as NSError where error.code == -1014 {
            XCTFail("Should have thrown error code 260 (file not found), not "
                    + "-1014 (zero byte resource). Possible cause is that a "
                    + "relative path was not resolved correctly.")
        }
    }

    func testMultipleSchemes() throws {
        do {
            let webService = try deserialize("multiple_schemes.wsdl")
            XCTAssertEqual(webService.schema.count, 2)
        } catch {
            XCTFail("Parse error: \(error)")
        }
    }

    func testRPCMessageWithType() {
        do {
            let webService = try deserialize("rpc_message_with_type.wsdl")
            XCTAssertNil(webService.messages.first?.parts.first?.element)
            XCTAssertNotNil(webService.messages.first?.parts.first?.type)
            XCTAssertEqual(webService.portTypes.first?.operations.first?.documentation, [
                "",
                "                This is the description of the `Test` operation.",
                "                Parameters:",
                "                * echo the `xs:string` to echo",
                "            "
                ].joined(separator: "\n"))
        } catch {
            XCTFail("Parse error: \(error)")
        }
    }

    func testSOAPMixedWithHTTPEndpoints() {
        let webService: WebServiceDescription
        do {
            webService = try deserialize("soap_mixed_with_http_endpoints.wsdl")
        } catch {
            return XCTFail("Could not parse WSDL: \(error)")
        }
        XCTAssertEqual(webService.bindings.count, 2)
        XCTAssertEqual(webService.bindings.first?.name, qname("ExampleSoap"))
        XCTAssertEqual(webService.bindings.map({ $0.operations }).count, 2)

        XCTAssertEqual(webService.messages.count, 6)
        XCTAssertEqual(webService.messages.first?.name, qname("GetSMSCodesSoapIn"))
        XCTAssertEqual(webService.messages.flatMap({ $0.parts }).count, 6)

        XCTAssertEqual(webService.portTypes.count, 3)
        XCTAssertEqual(webService.portTypes.first?.name, qname("ExampleSoap"))
        XCTAssertEqual(webService.portTypes.flatMap({ $0.operations }).count, 3)

        XCTAssertEqual(webService.schema.count, 3)
        XCTAssertEqual(webService.schema.first?.element?.name, qname("GetSMSCodes"))

        XCTAssertEqual(webService.services.count, 1)
        XCTAssertEqual(webService.services.first?.name, qname("Example"))
        XCTAssertEqual(webService.services.flatMap({ $0.ports }).count, 2)
    }

    func testBindingWithOtherNamespace() {
        let webService: WebServiceDescription
        do {
            webService = try deserialize("binding_with_other_namespace.wsdl")
        } catch {
            return XCTFail("Could not parse WSDL: \(error)")
        }
        XCTAssertEqual(webService.bindings.count, 1)
        XCTAssertEqual(webService.bindings.first?.name, QualifiedName(uri: "http://tempuri.org/other", localName: "Test"))
        XCTAssertEqual(webService.bindings.map({ $0.operations }).count, 1)

        XCTAssertEqual(webService.messages.count, 1)
        XCTAssertEqual(webService.messages.first?.name, qname("Message"))
        XCTAssertEqual(webService.messages.flatMap({ $0.parts }).count, 1)

        XCTAssertEqual(webService.portTypes.count, 1)
        XCTAssertEqual(webService.portTypes.first?.name, qname("Test"))
        XCTAssertEqual(webService.portTypes.flatMap({ $0.operations }).count, 1)

        XCTAssertEqual(webService.schema.count, 1)
        XCTAssertEqual(webService.schema.first?.element?.name, qname("MessageType"))

        XCTAssertEqual(webService.services.count, 1)
        XCTAssertEqual(webService.services.first?.name, qname("Test"))
        XCTAssertEqual(webService.services.flatMap({ $0.ports }).count, 1)
    }

    func testImportBindingInOtherNamespace() {
        let webService: WebServiceDescription
        do {
            webService = try deserialize("import_binding_in_other_namespace.wsdl")
        } catch {
            return XCTFail("Could not parse WSDL: \(error)")
        }
        XCTAssertEqual(webService.bindings.count, 1)
        XCTAssertEqual(webService.bindings.first?.name, QualifiedName(uri: "http://tempuri.org/other", localName: "Test"))
        XCTAssertEqual(webService.bindings.map({ $0.operations }).count, 1)

        XCTAssertEqual(webService.messages.count, 1)
        XCTAssertEqual(webService.messages.first?.name, qname("Message"))
        XCTAssertEqual(webService.messages.flatMap({ $0.parts }).count, 1)

        XCTAssertEqual(webService.portTypes.count, 1)
        XCTAssertEqual(webService.portTypes.first?.name, qname("Test"))
        XCTAssertEqual(webService.portTypes.flatMap({ $0.operations }).count, 1)

        XCTAssertEqual(webService.schema.count, 1)
        XCTAssertEqual(webService.schema.first?.element?.name, qname("MessageType"))

        XCTAssertEqual(webService.services.count, 1)
        XCTAssertEqual(webService.services.first?.name, qname("Test"))
        XCTAssertEqual(webService.services.flatMap({ $0.ports }).count, 1)
    }
}
