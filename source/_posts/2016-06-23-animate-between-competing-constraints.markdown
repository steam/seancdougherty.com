---
layout: post
title: "Animate between competing constraints"
date: 2016-06-23 08:27
comments: true
categories: iOS, Swift
---

I recently learned a new approach to animating two competing `NSLayoutConstraint`'s. 

**Problem**

Add a subview to a container and animate the subview from left to right using Auto Layout.

![Animating Box](/assets/layout-animation.gif)

**Solution**

1. Pin the leading edge of the pink box to it's container. Set it's `priority` to 999.
2. Pin the trailing edge of the pink box to it's container. Set it's `priority` to 998.
3. Swap the priorities of the leading and trailing constraints in the animation block.

```objective-c AnimatePinning.playground
/*
 Experiment that animates a red square left to right in a container
 by swapping the priority of the left and right layout constraints
*/

import UIKit
import XCPlayground

let container = UIView(frame: CGRectZero)
container.backgroundColor = .cyanColor()
container.translatesAutoresizingMaskIntoConstraints = false

let inner = UIView(frame: CGRectZero)
inner.translatesAutoresizingMaskIntoConstraints = false
inner.backgroundColor = .magentaColor()
container.addSubview(inner)

let innerWidth = NSLayoutConstraint(
    item: inner,
    attribute: .Width,
    relatedBy: .Equal,
    toItem: nil,
    attribute: .NotAnAttribute,
    multiplier: 1.0,
    constant: 200)

let innerHeight = NSLayoutConstraint(
    item: inner,
    attribute: .Height,
    relatedBy: .Equal,
    toItem: nil,
    attribute: .NotAnAttribute,
    multiplier: 1.0,
    constant: 200)

let containerWidth = NSLayoutConstraint(
    item: container,
    attribute: .Width,
    relatedBy: .Equal,
    toItem: nil,
    attribute: .NotAnAttribute,
    multiplier: 1.0,
    constant: 500)

let containerHeight = NSLayoutConstraint(
    item: container,
    attribute: .Height,
    relatedBy: .Equal,
    toItem: nil,
    attribute: .NotAnAttribute,
    multiplier: 1.0,
    constant: 300)

let top = NSLayoutConstraint(
    item: inner,
    attribute: .Top,
    relatedBy: .Equal,
    toItem: container,
    attribute: .Top,
    multiplier: 1.0,
    constant: 50
)

/* 
 1. Pin the leading edge of the pink box to it's container.
    Set it's `priority` to 999.
*/
let left = NSLayoutConstraint(
    item: inner,
    attribute: .Leading,
    relatedBy: .Equal,
    toItem: container,
    attribute: .Leading,
    multiplier: 1.0,
    constant: 0
)
left.priority = 999

/*
  2. Pin the trailing edge of the pink box to it's container. 
     Set it's `priority` to 998.
 */
let right = NSLayoutConstraint(
    item: inner,
    attribute: .Trailing,
    relatedBy: .Equal,
    toItem: container,
    attribute: .Trailing,
    multiplier: 1.0,
    constant: 0
)
right.priority = 998


NSLayoutConstraint.activateConstraints([
    innerWidth,
    innerHeight,
    containerWidth,
    containerHeight,
    top,
    left,
    right
])


// animate the inner square left -> right -> left
// by swapping the left and right constraint priorities
func animate() {
    UIView.animateWithDuration(1.0, animations: {
        let prevRight = right.priority
        let prevLeft = left.priority

        /*
          3. Swap the priorities of the two constraints
             in the animation block
        */
        left.priority = prevRight
        right.priority = prevLeft
        container.layoutIfNeeded()

        }, completion: { if $0 { animate() }})
}

animate()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = container

```