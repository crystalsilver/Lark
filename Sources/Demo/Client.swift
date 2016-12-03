import Foundation
import LarkRuntime

struct say_nothing: XMLSerializable, XMLDeserializable {
    init() { }
    init(deserialize node: XMLElement) throws { }
    func serialize(_ element: XMLElement) throws { }
}

struct say_nothingResponse: XMLSerializable, XMLDeserializable {
    init() { }
    init(deserialize node: XMLElement) throws { }
    func serialize(_ element: XMLElement) throws { }
}

struct stringArray: XMLSerializable, XMLDeserializable {
    let string: [String]

    init(string: [String]) {
        self.string = string
    }

    init(deserialize node: XMLElement) throws {
        self.string = try node.elements(forLocalName: "string", uri: "spyne.examples.hello").map(String.init(deserialize:))
    }

    func serialize(_ element: XMLElement) throws {
        for item in self.string {
            let string = try element.createElement(localName: "string", uri: "spyne.examples.hello")
            try item.serialize(string)
            element.addChild(string)
        }
    }
}

struct say_hello: XMLSerializable, XMLDeserializable {
    let name: [String]
    let times: [Int]

    init(name: [String], times: [Int]) {
        self.name = name
        self.times = times
    }

    init(deserialize node: XMLElement) throws {
        self.name = try node.elements(forLocalName: "name", uri: "spyne.examples.hello").map(String.init(deserialize:))
        self.times = try node.elements(forLocalName: "times", uri: "spyne.examples.hello").map(Int.init(deserialize:))
    }

    func serialize(_ element: XMLElement) throws {
        for item in self.name {
            let name = try element.createElement(localName: "name", uri: "spyne.examples.hello")
            try item.serialize(name)
            element.addChild(name)
        }
        for item in self.times {
            let times = try element.createElement(localName: "times", uri: "spyne.examples.hello")
            try item.serialize(times)
            element.addChild(times)
        }
    }
}

struct say_maybe_nothing: XMLSerializable, XMLDeserializable {
    let name: [String]

    init(name: [String]) {
        self.name = name
    }

    init(deserialize node: XMLElement) throws {
        self.name = try node.elements(forLocalName: "name", uri: "spyne.examples.hello").map(String.init(deserialize:))
    }

    func serialize(_ element: XMLElement) throws {
        for item in self.name {
            let name = try element.createElement(localName: "name", uri: "spyne.examples.hello")
            try item.serialize(name)
            element.addChild(name)
        }
    }
}

struct say_maybe_nothingResponse: XMLSerializable, XMLDeserializable {
    let say_maybe_nothingResult: [String]

    init(say_maybe_nothingResult: [String]) {
        self.say_maybe_nothingResult = say_maybe_nothingResult
    }

    init(deserialize node: XMLElement) throws {
        self.say_maybe_nothingResult = try node.elements(forLocalName: "say_maybe_nothingResult", uri: "spyne.examples.hello").map(String.init(deserialize:))
    }

    func serialize(_ element: XMLElement) throws {
        for item in self.say_maybe_nothingResult {
            let say_maybe_nothingResult = try element.createElement(localName: "say_maybe_nothingResult", uri: "spyne.examples.hello")
            try item.serialize(say_maybe_nothingResult)
            element.addChild(say_maybe_nothingResult)
        }
    }
}

struct say_maybe_something: XMLSerializable, XMLDeserializable {
    let name: [String]

    init(name: [String]) {
        self.name = name
    }

    init(deserialize node: XMLElement) throws {
        self.name = try node.elements(forLocalName: "name", uri: "spyne.examples.hello").map(String.init(deserialize:))
    }

    func serialize(_ element: XMLElement) throws {
        for item in self.name {
            let name = try element.createElement(localName: "name", uri: "spyne.examples.hello")
            try item.serialize(name)
            element.addChild(name)
        }
    }
}

struct say_maybe_somethingResponse: XMLSerializable, XMLDeserializable {
    let say_maybe_somethingResult: [String]

    init(say_maybe_somethingResult: [String]) {
        self.say_maybe_somethingResult = say_maybe_somethingResult
    }

    init(deserialize node: XMLElement) throws {
        self.say_maybe_somethingResult = try node.elements(forLocalName: "say_maybe_somethingResult", uri: "spyne.examples.hello").map(String.init(deserialize:))
    }

    func serialize(_ element: XMLElement) throws {
        for item in self.say_maybe_somethingResult {
            let say_maybe_somethingResult = try element.createElement(localName: "say_maybe_somethingResult", uri: "spyne.examples.hello")
            try item.serialize(say_maybe_somethingResult)
            element.addChild(say_maybe_somethingResult)
        }
    }
}

struct say_helloResponse: XMLSerializable, XMLDeserializable {
    let say_helloResult: stringArray

    init(say_helloResult: stringArray) {
        self.say_helloResult = say_helloResult
    }

    init(deserialize node: XMLElement) throws {
        guard let say_helloResult = node.elements(forLocalName: "say_helloResult", uri: "spyne.examples.hello").first else {
            throw XMLDeserializationError.noElementWithName("say_helloResult")
        }
        self.say_helloResult = try stringArray(deserialize: say_helloResult)
    }

    func serialize(_ element: XMLElement) throws {
        let say_helloResult = try element.createElement(localName: "say_helloResult", uri: "spyne.examples.hello")
        try self.say_helloResult.serialize(say_helloResult)
        element.addChild(say_helloResult)
    }
}

class HelloWorldServiceClient: Client {
    func say_nothing(input: say_nothing, output: (say_nothingResponse) -> ()) throws {
        let parameter = XMLElement(prefix: "ns0", localName: "say_nothing", uri: "spyne.examples.hello")
        parameter.addNamespace(XMLNode.namespace(withName: "ns0", stringValue: "spyne.examples.hello") as! XMLNode)
        try input.serialize(parameter)
        try send(parameters: [parameter], output: { body in
            let element = body.elements(forLocalName: "say_nothingResponse", uri: "spyne.examples.hello").first!
            output(try say_nothingResponse(deserialize: element))
        })
    }

    func say_maybe_something(input: say_maybe_something, output: (say_maybe_somethingResponse) -> ()) throws {
        let parameter = XMLElement(prefix: "ns0", localName: "say_maybe_something", uri: "spyne.examples.hello")
        parameter.addNamespace(XMLNode.namespace(withName: "ns0", stringValue: "spyne.examples.hello") as! XMLNode)
        try input.serialize(parameter)
        try send(parameters: [parameter], output: { body in
            let element = body.elements(forLocalName: "say_maybe_somethingResponse", uri: "spyne.examples.hello").first!
            output(try say_maybe_somethingResponse(deserialize: element))
        })
    }

    func say_hello(input: say_hello, output: (say_helloResponse) -> ()) throws {
        let parameter = XMLElement(prefix: "ns0", localName: "say_hello", uri: "spyne.examples.hello")
        parameter.addNamespace(XMLNode.namespace(withName: "ns0", stringValue: "spyne.examples.hello") as! XMLNode)
        try input.serialize(parameter)
        try send(parameters: [parameter], output: { body in
            let element = body.elements(forLocalName: "say_helloResponse", uri: "spyne.examples.hello").first!
            output(try say_helloResponse(deserialize: element))
        })
    }

    func say_maybe_nothing(input: say_maybe_nothing, output: (say_maybe_nothingResponse) -> ()) throws {
        let parameter = XMLElement(prefix: "ns0", localName: "say_maybe_nothing", uri: "spyne.examples.hello")
        parameter.addNamespace(XMLNode.namespace(withName: "ns0", stringValue: "spyne.examples.hello") as! XMLNode)
        try input.serialize(parameter)
        try send(parameters: [parameter], output: { body in
            let element = body.elements(forLocalName: "say_maybe_nothingResponse", uri: "spyne.examples.hello").first!
            output(try say_maybe_nothingResponse(deserialize: element))
        })
    }
    
}
