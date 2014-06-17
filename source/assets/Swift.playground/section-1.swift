/*  Variables

    Swift is able to infer type information in most cases so specifying
    it is not required if a value is assigned by the expression.
*/

// Swift knows this is a string because the right hand value is a string
var name = "Walter"

// variable and constant types are specified after the name and a colon
var lastName : String = "White"

var age = 1 // inferred to Int

var explictAge : Int = 1 // explicitly set to Int

var count = 1.0 // inferred to Double

var explicitCount : Double = 1 // force to an int


/*  Constants

    The Swift documentation favors immutability so constants are highly 
    visible in the language. Constants are indicated using the `let` 
    keyword in place of `var`.
*/

let immutableName = "Walter" // an immutable string constant

// immutableName = "Walter White" // won't compile

var mutableName = "walter" // a mutable string variable

mutableName = "Walter White" // works


/*  String

    Strings are concatenated with the `+` operator. They can be added 
    to with the `+=` operator. Strings can also interpolate other 
    calculated values using a backslash followed by the expression 
    in parenthesis `\(expression)`.
*/

var nameDescription = "Walter"
nameDescription += " White" // name = "Walter White"

let yearsOld = 50
nameDescription += " is \(yearsOld) years old" // name = "Walter White is 50 years old"


/* Collections

    Swift has several collection types. The most common are `Array` 
    and `Dictionary`. Just like strings and the number types they are 
    mutable if they are variables and immutable when they are constants.

*/

/*  Array
    Arrays are typed in Swift.
*/

var integers : Int[] = [1, 2, 3]
// integers += "non integer" // will not compile

// If the type can be inferred the type information is not required at declaration time.

var characters = ["Jesse", "Walter", "Hank"] // inferred as an array of strings

characters += "Skyler" // add a string to the array

characters[2] // "Hank"


/* Dictionary */

var states : Dictionary<String, Int> = [
    "Colorado" : 5000000,
    "Hawaii" : 1000000
]

var shows = [
    "Walter" : "Science Teacher",
    "Jesse" : "Unemployed",
    "Hank" : "DEA Agent"
] // type inferred to a key type String and value type String

shows["Jesse"] // "Unemployed"

shows["Skyler"] = "Accountant" // add an element to the dictionary


/* Control Flow

    Swift has most of the familiar mechanisms for controlling flow that 
    Objective-C developers are familiar with. They're just a lot cooler 
    and more useful in Swift.
*/


var registered = true

if registered {
    // if statements do not require parenthesis
    // but they do require curly braces
}

// Swift has range types that are enumerable
for number in 5...10 {
    println("\(number) plus \(number) is \(number + number)")
}

let breakingBadCharacters = ["Jesse", "Walter", "Hank"]

for character in breakingBadCharacters {
    println("\(character)")
}

// a string's characters are enumerable
for letter in "Breaking Bad" {
    println(letter)
    letter
}

var funds = 0
while funds < 10 {
    // cook meth until broke is false
    funds++
}

do {
    // cook meth at least once
    funds++
} while funds < 100

// Dictionaries are enumerable as a key value tuple pair. More on tuples below.

let cast = [
    "Walter" : "Science Teacher",
    "Jesse" : "Unemployed",
    "Hank" : "DEA Agent"
]

for (name, profession) in cast {
    "\(name) is a \(profession)"
}


/* Switch

    The coolest and most powerful control flow mechanism in Swift is the switch
    statement. Swift's switch statement works with any type compared to
    Objective-C's integer only switching. Swift switch allows for pattern 
    matching, a powerful feature new to iOS and OS X development.

    Switch statements must be exhaustive so a default is required if the case 
    statements don't handle all possible cases. Execution does not fall through 
    case statements so no `break` keyword is necessary.
*/

let fullName = "Walter White"
var output = ""

switch fullName {
case let x where countElements(fullName) > 3:
    output = "more than 3 characters long"
case "Jesse", "Hank":
    output = fullName
case let x where x.hasSuffix("White"):
    output = "ends in White"
default:
    output = "no matches found"
}
output // "more than 3 characters long"



/* Functions

    Functions are types just like everything else in Swift. 
    You can define them, call them as well as passing them as arguments to 
    another function and return them from other functions. Functions are 
    defined using the `func` keyword. They accept 0 or more arguments 
    and may return a value. A function returns a value with a `->` 
    and type after the parentheses.
*/


func add(a:Int, b:Int) -> Int {
    return a + b;
}

let sum = add(5,7)

sum // 12


/*  In order to remain compatible with Cocoa and Cocoa Touch function 
    arguments can have an external name as well as an internal variable
    name. Lets look at a `UITableViewDataSource` protocol method in 
    both Objective-C and Swift.
*/

//  Objective-C
//  - (UITableViewCell *)tableView:(UITableView *)tableView
//      cellForRowAtIndexPath:(NSIndexPath *)indexPath;

//  Swift
//  notice that the first argument does not have an external name
//  while the second argument is named cellForRowAtIndexPath externally
//  and indexPath internally

//  func tableView(tableView: UITableView!,
//      cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!


/*  The Cool New Hotness

    The language features below are either completely new compared to 
    Objective-C or they work in ways novel enough to note here.

    Optionals

    As I mentioned above, Swift is designed to be safe. Optionals help 
    keep code safe by forcing the developer to be explicit about variables
    and constants. By default all variables and constants must have an 
    assigned value. This ensures that it is safe to use variables and 
    constants without first checking to see if they have a value. 
    However, sometimes we'll need optional value variables or constants. 
    This is where Swift Optionals come in. Optionals are a formal language 
    feature that marks a variable or constant as potentially having no value. 
    To mark a variable or constant as optional use a `?` after the type.

*/

var content:String?

func isDone() -> Bool? { return nil }

func storeUserInfo(name:String?, age:Int?) {}


//  When using an optional variable or function with an optional return 
//  value we must explicitly unwrap the value held by the optional using
//  a `!` after the referenced optional.


content = "Some content here"

//content // compile error

println(content!) // compiles but may introduce a run time crash if content is nil

if content {
    println(content!) // safe because optionals are true if they have a value
}

// automatic unwrapping with if let shorthand
if let safeContent = content {
    safeContent // preferred handling of optionals
}


/*  Tuples

    Tuples are a group of compound values. 
    To create a tuple enclose multiple values in parentheses. 
    They can contain any number of values as well as any combination of types. 
    The values can have names or not. Tuples are the mechanism for 
    returning more than one value from a function. 
    Access values in a tuple by position or name.
*/

var ages = (10, 15, 20)

ages.1 // 15

func getNames() -> (tom:String, dick:String, harry:String) {
    return ("Tom", "Dick", "Harry")
}

let (tom, dick, harry) = getNames()

harry // "Harry"

getNames().dick // "Dick"


/* Enums

    Enums are useful for storing a known list of enumerable values. 
    Swift enums support functions as well.
*/

enum Framework {
    case CocoaTouch, Rails, Android
    func language() -> String {
        switch self {
        case .CocoaTouch:
            return "Swift"
        case .Rails:
            return "Ruby"
        case .Android:
            return "Java"
        }
    }
}
let rails = Framework.Rails
let railsLanguage = rails.language() // "Ruby"


/*  Structs
    
    Structs are similar to classes in Swift with the distinction 
    that they are immutable by default. They are copied when 
    passed in code. Classes are passed by reference.

*/


struct Programmer {
    var name : String
    var framework : Framework

    func frameworkLanguage() -> String {
        return framework.language()
    }
}

let cocoaProgrammer = Programmer(name:"Sean", framework:.CocoaTouch)
let frameworkLanguage = cocoaProgrammer.frameworkLanguage()



/*  Generics

    Generics are a powerful tool for code reuse. They abstract 
    code and provide flexibility while maintaing compile time 
    type safety. Under the hood Swift uses generics for a host 
    of the standard library features including collections like 
    Array and Dictionary.

    The Swift Programming Language: https://itun.es/us/jEUH0.l 
    has a great example of generics. The example is a simple 
    `Stack`. In order to make the stack work with with any 
    type generics are used. The stack is type safe but flexible 
    enough to hold any type.

*/

struct Stack<T> {
    var items = T[]()

    mutating func push(item: T) {
        items.append(item)
    }

    mutating func pop() -> T {
        return items.removeLast()
    }
}

var stackOfStrings = Stack<String>()
stackOfStrings.push("uno")
stackOfStrings.push("dos")
stackOfStrings.push("tres")
stackOfStrings.push("cuatro")
// the stack now contains 4 strings

//stackOfStrings.push(123) // won't compile because 123 is not a String


/*  Extensions
    Extensions allow you to add functionality to existing types. 
    They are similar to Objective-C's categories and Ruby's Modules. 
    Unlike an Objective-C category a Swift Extension can extend 
    classes, structures and enums. Extensions can also add computed 
    properties and add protocal conformance to an existing type. 
    Extensions are available app wide at compile time.
*/


extension Double {
    func multiply(b:Double) -> Double {
        return self * b
    }
}

5.5.multiply(3) // 16.5


/*  Protocols
    
    Swift Protocols are similar to protocols in Objective-C but like 
    their Extension counterparts they available on all types. Protocols 
    are similiar to Java's Interfaces. When a type adopts a protocol it 
    is conforming to a contract defined by the protocol. Protocols 
    define optional or required functions and/or properties. The best 
    new feature of protocols in Swift are protocol instance properties. 
    Protocols do not define the implementation of their functions or 
    properties, concrete types conforming to the protocol implement 
    all required functions and properties.

*/

protocol HighFiveable {
    var numberOfHighFives: Int { get }

    func highFive()
}

class Person: HighFiveable {
    var numberOfHighFives = 20

    func highFive() {
        println("I was high fived!")
    }
}

let jim = Person()

jim.highFive() // "I was high fived!"
