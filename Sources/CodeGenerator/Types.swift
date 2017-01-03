import Foundation
import SchemaParser

// MARK:- SOAP Types

extension ComplexType {
    func toSwift(name: String? = nil, mapping: TypeMapping, types: Types) -> SwiftTypeClass {
        let name = name ?? mapping[.type(self.name!)]!
        var properties = [SwiftProperty]()
        var nestedTypes = [SwiftMetaType]()
        switch self.content {
        case let .sequence(sequence):
            for element in sequence.elements {
                switch element.content {
                case let .base(base):
                    properties.append(SwiftProperty(name: element.name.localName.toSwiftPropertyName(), type: .init(type: mapping[.type(base)]!, element: element), element: element))
                case let .complex(complex):
                    nestedTypes.append(complex.toSwift(mapping: mapping, types: types))
                    properties.append(SwiftProperty(name: element.name.localName.toSwiftPropertyName(), type: .init(type: "UNNAMED", element: element), element: element))
                }
            }
        case .empty: break
        }

        return SwiftTypeClass(name: name, properties: properties, nestedTypes: nestedTypes)
    }
}

extension SimpleType {
    func toSwift(name: String? = nil, mapping: TypeMapping, types: Types) -> SwiftMetaType {
        let name = name ?? mapping[.type(self.name!)]!
        switch self.content {
        case .list: fatalError()
        case .listWrapped:
            fatalError("Not implemented")
//            return SwiftTypeClass(
//                name: "ArrayOf\(name)",
//                properties: [SwiftProperty(name: "items", type: .array(.identifier(name)))],
//                nestedTypes: [wrapped.toSwift(name: name, mapping: mapping)]
//            )
        case let .restriction(restriction):
            let cases = restriction.enumeration.dictionary({ ($0.toSwiftPropertyName(), $0) })
            return SwiftEnum(name: name, rawType: .identifier("String"), cases: cases)
        }
    }
}

extension Element {
    func toSwift(mapping: TypeMapping, types: Types) -> SwiftTypeClass {
        let name = mapping[.element(self.name)]!
        switch self.content {
        case let .base(base): return SwiftTypeClass(name: name, base: (types[.type(base)]! as! SwiftTypeClass))
        case let .complex(complex): return complex.toSwift(name: name, mapping: mapping, types: types)
        }
    }
}


// MARK:- SOAP Client

extension Service {
    func toSwift(wsdl: WSDL, types: Types) -> SwiftClientClass {
        // SOAP 1.1 port
        let port = ports.first { if case .soap11 = $0.address { return true } else { return false } }!
        let binding = wsdl.bindings.first { $0.name == port.binding }!
        let portType = wsdl.portTypes.first { $0.name == binding.type }!

        let name = "\(self.name.localName.toSwiftTypeName())Client"

//        types.first!.value.name

        let message = { (messageName: QualifiedName) -> (QualifiedName, Identifier) in
            let message = wsdl.messages.first { $0.name == messageName }!
            let element = message.parts.first!.element
            return (element, types[.element(element)]!.name)
        }

        //TODO: zip operations first; combinding port.operation and binding.operation
        let methods = portType.operations
            .map { operation in (port: operation, binding: binding.operations.first(where: { $0.name == operation.name })!) }
            .map { operation -> ServiceMethod in
//                let inputMessage = wsdl.messages.first { $0.name == operation.port.inputMessage }!
//                let inputElement = input.parts.first!.element
//                let input = (inputElement, types[.element(inputElement)]!)
//                let output = wsdl.messages.first { $0.name == operation.port.outputMessage }!
                let input = message(operation.port.inputMessage)
                let output = message(operation.port.outputMessage)

                return ServiceMethod(operation: operation.port, input: input, output: output, action: operation.binding.action)
            }

        return SwiftClientClass(name: name, methods: methods, port: port)
    }
}
