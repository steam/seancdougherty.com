---
layout: post
title: "Big-O Notation"
date: 2016-05-31 11:39
comments: true
categories: swift, iOS
---

Any time a blog post, colleague or programming book uses big O notation I glance at it, record some general impression of the function/algorithm's performance and move on. I know that big O notation describes how the rate of computation time changes as the input size grows. Or more simply put, big O communicates the efficiency of a function. What I've been missing are the specifics about how an algorithm's big O notation is calculated and when one algorithm is more preferable to another. 

Big O describes the efficiency of an algorithm when it operates on an arbitrarily large set of data and describe a 'worst case' scenario. Often times the performance characteristics of an algorithm are different for smaller sets of data.

At the most efficient end of the spectrum are *_constant time_* algorithms. These are functions that (basically) take the same amount of time regardless of the input size. Constant time is expressed as `O(1)`. The following example is a constant time function because hash-based lookups in Swift do not require enumeration over the entire collection.

```objective-c 
// hash-based lookups on a swift dictionary are O(1) 
func age(name: String) -> Int? {
    let names = ["jane": 30, "john": 25, "sam": 19]
    return names[name]
}
```

Another very common notation is *_linear time_* which is represented as `O(n)`. A linear algorithm's execution time grows linearly with the size of it's input. This simple array lookup has a complexity of `O(n)` because it (potentially) requires enumerating the entire collection to produce a result.

```objective-c 
// enumerating a simple swift array is O(n) 
// there are more efficient ways to write this code
func ageFound(age: Int) -> Bool {
    let values = [30, 25, 19]
    for value in values {
        if value == age { 
            return true 
        }
    }
    return false
}
```

*_Quadratic time_*, written as `O(n2)` describes an algorithm that grows quadratically. Increasing the input size by a single unit increases the workload by an order of magnitude. The easiest way to visualize `O(n2)` involves a loop nested in a loop. For each element in the outer loop the algorithm must loop through every element in the inner loop.

```objective-c 
// printing out all the combinations of two arrays of strings is `O(n2)`
// suits and ranks taken from the excellent book `Advanced Swift` by 
// Chris Eidhof and Airspeed Velocity
func combineSuitsAndRanks() {
    let suits = ["♠︎", "♥︎", "♣︎", "♦︎"]
    let ranks = ["J","Q","K","A"]
    for rank in ranks {
        for suit in suits {
            print(rank + suit)
        }
    }
}
```

`O(log n)` describes *_logarithmic time_*. An algorithm that can repeatedly subdivide the work in such a way that doubling the size of the data does not double the amount of work required to complete the algorithm. The commonly cited example of `O(log n)` is a binary search. Wayne Bishop's "Swift Algorithms & Data Structures." and Chris Eidhof and Airspeed Velocity's "Advanced Swift" both have great implementations of binary search in Swift.

Knowing the performance characteristics of the code we write allows us to objectively evaluate and improve it. Big O can be a helpful tool for us to make decisions about our own code as well as 3rd party code that we use in our apps.

There are many more examples of big O notation, *_linearithmic time_* `O(n log n)`, *_cubic time_* `O(n3)`, *_exponential time_* `2poly(n)`, *_factorial time_* `O(n!)`, *_polylogarithmic time_* `poly(log n)`, etc.

See anything that looks wrong? Please let me know. I'm intending to write a handful of posts about subjects that require me to do some research in order to write (semi) intellegently about them so I won't be sore if you correct my mistakes 😜.

For more reading on big O notation checkout:

* [Wikipedia](https://en.wikipedia.org/wiki/Big_O_notation)
* [Swift Algorithms & Data Structures.](http://waynewbishop.com/swift/) by Wayne Bishop
* [Big-O notation explained by a self-taught programmer](https://justin.abrah.ms/computer-science/big-o-notation-explained.html)
* [Big O Notation Time and Space Complexity](https://www.interviewcake.com/article/java/big-o-notation-time-and-space-complexity)
