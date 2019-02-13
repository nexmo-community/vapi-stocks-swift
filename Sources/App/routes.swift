import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    
    router.get("/answer") { request -> String in
        return """
[
    {
        "action": "talk",
        "text": "Welcome to a Voice API I V R.",
        "voiceName": "Amy",
        "bargeIn": false
    },
    {
        "action": "talk",
        "text": "Press 1, for Vonage, 2, for Apple, and 3, for Microsoft, followed by the hash key.",
        "voiceName": "Amy",
        "bargeIn": true
    },
    {
        "action": "input",
        "eventUrl": ["http://vapi-stocks-swift.herokuapp.com/dtmf"]
    }
]
"""
    }
    
    
    
    struct DTMF: Decodable {
        let dtmf: String
    }
    struct Quote: Decodable {
        let Name: String
        let LastPrice: Double
        let Timestamp: String
    }
    
    
    router.post("/dtmf") { request -> String in
        print("request: \(request)")
        guard let data = request.http.body.data, let body = String(data: data, encoding: .utf8) else {
            return "[{ \"action\": \"talk\", \"text\": \"Invalid response\"}]"
        }
        print("-------------")
        print("request body: \(body)")
        print("-------------")
        
        guard let dtmf = try? JSONDecoder().decode(DTMF.self, from: data) else {
            print("Error: Couldn't decode data into Blog")
            return "[{ \"action\": \"talk\", \"text\": \"Invalid JSON\"}]"
        }
        var symbol = "VG"
        switch dtmf.dtmf {
        case "2":
            symbol = "AAPL"
        case "3":
            symbol = "MSFT"
        default:
            symbol = "VG"
        }
        guard let url = URL(string: "http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol=\(symbol)"),
            let quoteJSON = try? Data(contentsOf: url),
            let quote = try? JSONDecoder().decode(Quote.self, from: quoteJSON) else {
                return "[{ \"action\": \"talk\", \"text\": \"Invalid data source\"}]"
        }
        
        return """
[
    {
        "action": "talk",
        "text": "Last price for \(quote.Name) was \(quote.LastPrice)"
    }
]
"""
    }
    
}
