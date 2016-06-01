---
layout: post
title: "More Functional Please"
date: 2014-12-31 10:43
comments: true
categories: swift, iOS
---

Since starting the Ello iOS app I've been writing Swift 99% of the time. Its not yet as natural as Objective-C to me but the benefits are obvious. A concise syntax with ALL types as first class citizens has removed a lot of the primitive/object song and dance required in Objective-C. I knew I'd love Swift's syntax and type system. What I've been surprised by, and excited by, are Swift's functional features. Most of the interesting exploration and writing about Swift has come from the Functional programming community. I have to admit that almost all of the functional programming concepts are new to me. Like most Objective-C developers I come from a world of strict object orientation and an imperative programming mindset.

This new (to me) functional approach has opened up a world of new techniques and tools I'm convinced will make my code easier to maintain and less error prone. The takeaway for me so far is that functional programming's primary benefit is removing as much concern about state as possible while focusing on the **WHAT** instead of the **HOW**.

Managing state is one of the most common problems we encounter when building a reasonably sized application. It starts out simple at first. An instance variable here, another one over there. State instance variables are cheap and convenient. They help you solve an immediate problem and allow you to get back to the function or task at hand. The problem is that they introduce huge complexity as a system grows. Their intended usage and area of influence becomes unclear. A bit like the story of the boiling frog they add complexity little by little over time. Before you've recognized it the application is in big trouble. The problem is that if they're not rigorously maintained they can add untold hours of development to the life of an application.

Functional programming favors immutability over mutable objects. At first this seemed wasteful to me. Why create something new each time when I already have an available object. Turns out that the stability of data structures not changing is usually worth the small trade off of allocating a new one.

I recently came across Rob Napier's slides from his talk ["Introduction to functional programming in Swift"](https://speakerdeck.com/rnapier/llama-calculus) from CocoaConf Atlanta 2014. Its a great set of slides that I encourage you to read if you're interested in a more in depth look at functional concepts and motivations. The example below is a simple example of using Swift's `map` function in place of the traditional for loop.

This code is a simplified version of code we have in the Ello app. Posts represent a user's post. Regions are sections of content in a post. Our goal is to create an array of `String` types, each containing the content for an individual region. Simple enough.

```objective-c 
struct Region {
  let content:String
  
  init(content:String) {
      self.content = content
  }
}

struct Post {
  let regions:[Region]

  init(regions:[Region]) {
      self.regions = regions
  }
}

```

An array of `strings` using the imperative for loop. We pass in an array of posts, loop over them, inner loop over their regions and append each region's content property to a temporary array and return it.

This is slightly contrived and unlikely to appear in the wild (hopefully) but it illustrates the most imperative way we can solve the problem. Most of the syntax is focused on the **how**. We have three temporary variables `regions`, `i` and `j`, subscripting, lots of the machinery is exposed.

```objective-c 
func regions(posts:[Post]) -> [String] {
  var regions = [String]()
  for var i = 0; i < posts.count; i++ {
      let post = posts[i]
      for var j = 0; j < post.regions.count; j++ {
          let region = post.regions[j]
          regions.append(region.content)
      }
  }
  return regions
}

```

Lets solve the problem using Swift's `Array.map` function. `map` enumerates the array handing your function one element from the array. You do whatever you want with the element and hand back the type you specify as the return value. Here we map over posts and for each post in posts we map over it's regions. For each region we return it's `content` property. Notice the use of the `join` function. `join` is a handy function most commonly used to convert an array of strings into a single string. In this case we use it to turn an array of arrays into a flattened array.

```objective-c 
func regions(posts:[Post]) -> [String] {
  return join([],
      posts.map { post in
          post.regions.map { $0.content }
      })
}

```

The functional approach uses no temporary variables and focuses on the **what** rather than the **how**. In this case it's more succinct as well.

These concepts are definitely Functional Programming 101 (or maybe even a pre-requisite) but they're easily understandable and were my gateway drug into more sophisticated functional techniques. I'm still a strong believer in object orientation and intend to remain one but functions like `map` are fantastic new tools we can use to make our Swift code more readable, safer and less error prone.

I consider myself a n00b when it comes to functional thinking. Our backend counterparts in the ruby world have used these techniques for years. My goal is to find situations where I can challenge my existing mode of imperative problem solving with a functional approach. I'm convinced my code will be more stable, more readable and more portable. Plus, this stuff is just plain fun.
