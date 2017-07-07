---
layout: blog
title: '[Book Summary] 속깊은 Javascript 4/9'
date: 2017-06-29 14:35:43
categories:
- Book Summary
tags:
- javascript
---

{% asset_img cover.jpg %} 

# Chapter 4. 프로토타입과 객체지향, 그리고 상속

## 4.1. 프로토타입을 통한 객체지향

### 4.1.1. 프로토타입의 정의

> 프로토타입이란 Javascript가 제공하는 객체 지향을 지원하기 위한 방법이다. Java의 상속과는 다르게 동적으로 부모 객체의 수정이 가능하다.

### 4.1.2. 자바스크립트와 자바의 객체 생성 비교

{%codeblock "Java" lang:java%}
class Person {
    String name;
    String blog;
    
    public Person(String name, String blog) {
        this.name = name;
        this.blog = blog;
    }
}
{%endcodeblock%}

자바와 비슷하지만 자바스크립트는 function으로 선언한다. 단, ECMAScript 6에서는 class 키워드가 추가되었다.
{%codeblock "Javascript" lang:javascript%}
function Person(name, blog) {
    this.name = name;
    this.blog = blog;
}
{%endcodeblock%}

### 4.1.3. this의 이해

자바스크립트에서의 this 가 무엇을 참조하는지는 **"호출 방법"** 에 따라서 변경이 된다. (스코프가 아님)

{%codeblock "this in javascript" lang:javascript%}
function Person(name, blog) {
    this.name = name;
    this.blog = blog;
}
{%endcodeblock%}

#### "일반 함수 내에서의 this는 Window 객체를 참조한다."

{%codeblock "" lang:javascript%}
function foo() {
    console.log(this);
}

foo(); // Window {...}
{%endcodeblock%}

#### "맴버 함수 내에서의 this는 해당 함수를 포함하는 객체를 참조한다."

{%codeblock "" lang:javascript%}
var obj = {
    foo : function () {
        console.log(this);
    }
}
obj.foo(); // Object {...}
{%endcodeblock%}

#### "call()과 apply()는 첫 번째 파라미터로 this를 넘길 수 있다."

```call()```과 ```apply()```를 이용하여 함수를 호출하면, 해당 함수 내에서의 ```this```를 바꿀 수 있다. 


{%codeblock "" lang:javascript%}
function foo() {
    console.log(this, this.bar);
}
var obj = {
    bar : "bar"
};
foo.call(obj); // bar
{%endcodeblock%}

위와 같이 ```obj```객체를 파라미터로 넘겨주어 ```foo``` 함수의 실행 컨텍스트를 바꿀 수 있다. ```call```의 파라미터가 없거나, 파라미터로 ```undefined```나 ```null``` 을 주면 함수 내부에서의 ```this```는 Window 객체를 가르킨다. 일반적으로 함수에서는 내부적으로 ```call```을 파라미터 없이 호출하게 되고, 그 때의 ```this```는 ```Window``` 객체를 가르키게 된다고 한다. ```call```과 ```apply```의 차이는 파라미터를 객체로 줄수 있는지의 차이이다.

### 4.1.4. new 키워드

```new``` 키워드의 파라미터로 함수를 넘기면, 그 내부 동작이 표준에서 정의한대로 동작하는데 그 표준을 이 책에서 설명한다. 만약 아래의 코드를 ```new```가 아니라 그냥 다음과 같이 호출해 버리면, ```this```가 ```Window```을 참조하기 때문에 글로벌 변수 두개를 생성하는 웃긴 결과가 될것이다.

{%codeblock "Javascript" lang:javascript%}
function Person(name, blog) {
    this.name = name;
    this.blog = blog;
}

Person("my name","my blog");
console.log(window.name); // my name
{%endcodeblock%}

하지만, ```new Person("my name","my blog")``` 으로 호출 함으로써 내부적으로 다음의 절차를 따르게 된다. 책의 설명이 이해가 안되서 직접 찾아 봄. [참고: ecma-internal]("http://www.ecma-international.org/ecma-262/5.1/#sec-11.2.2")
1. new는 몇가지 체크 후, 내부 함수인 [[Construct]]를 호출한다.
1. [[Construct]]는 다음의 절차를 따른다.
    1. 새로운 object인 obj생성한다.
    1. 파라미터인 함수 F의 prototype을 obj에 설정한다.
    1. F의 내부 함수인 [[Call]]을 호출 하는데, 이때 obj와 파라미터를 넘겨 obj를 초기화 시킨다. (예제에서의 obj.name와 obj.blog가 셋팅되는 과정)
    1. obj를 리턴한다.
    
### 4.1.5. 프로토타입에 대한 표준 정의

> prototype은 다른 객체들과 공유되는 속성을 제공하는 객체이다. 

{%codeblock "prototype" lang:javascript%}
function Person(name, blog) {
  this.name = name;
  this.blog = blog;
}
// 프로토타입과 생성자 함수는 서로 링크되어 있다.
console.log(Person.prototype); // Object {}
console.log(Person.prototype.constructor); // function Person() {}
{%endcodeblock%}

프로토타입의 정의와 특성에 대해서는 [이 곳]("http://www.nextree.co.kr/p7323/") 에 더 잘나와 있다.

### 4.1.6. 프로토타입의 사용 예
이 장에서는 프로토타입의 실제 동작 방식을 예제로 설명한다.

#### "객체 생성 후에도 prototype 수정이 가능하다"
다른 언어를 다루던 사람은 객체를 생성할 때, 객체를 찍어 낸다고 생각하기 때문에 한번 찍어낸 객체는 그대로 동작하야 한다고 믿을 수 있다. prototype과 같은 공유 객체를 생각하기 어려울 것이다. 그러나 자바스크립트에서는 그 이후 prototype을 얼마든지 수정이 가능하고, 그럼 각 객체의 기능에도 영향을 받을 수 있다. 

{%codeblock "use of the prototype" lang:javascript%}
// 생성자 함수
function Foo(bar) {
  this.bar = bar;
}
// 프로토타입에 함수 추가
Foo.prototype.getBar = function() {
  return this.bar;
};
// 객체 생성
var foo1 = new Foo("bar");
var foo2 = new Foo("bar");
console.log(foo1.getBar()); // bar
console.log(foo2.getBar()); // bar

// 프로토타입 함수 변경
Foo.prototype.getBar = function() {
  return "new " + this.bar;
};
console.log(foo1.getBar()); // new bar
console.log(foo2.getBar()); // new bar

// 프로토타입에 변수 추가
Foo.prototype.abc = "abc";
console.log(foo1.abc); // abc
console.log(foo2.abc); // abc
{%endcodeblock%}

### 4.1.7. 프로토타입과 생성자
이 책에서 가장 난해한 부분 중 하나이다. 용어가 부터가 통일 되지 않는다. "constructor", "생성자", "생성자 함수", "프로토타입의 constructor 속성", "객체의 constructor 속성"은 모두 잘 구분되어야 하는데 마구 섞어 있다. 나름대로 이해한 바를 정리해 본다.

#### "function 키워드로 contructor 속성이 만들어 진다."
위 예제에서 ```Foo.protoype.constructor```는 ```funtion Foo```에 의해서 만들어진다. 책에서 설명하는 MakeConstructor는 아마도 이 과정일 것이다. 두개의 객체가 생성되는데 하나는 **Foo 함수 객체** 이고 다른 하나는 **Foo의 prototype 객체** 이다. 상호 참조를 가지고 있으므로 접근이 가능하다. 

{% asset_img proto1.png "constructor and prototype" %}

#### "new + 생성자 함수 구문으로 새로운 객체를 만든다."
```new Foo()```를 이용하면, 맴버 변수들의 초기화를 위해서 생성자 함수를 한번 실행 하고 새로운 객체를 만든다. 새로운 객체는 ```Foo의 prototype 객체```에 대해서 내부링크(implicit prototype link)를 가지게 된다. 그림에서 보이는 __proto__가 그 것이다. __proto__ 속성은 만들어진 객체의 내부 속성인 [[Prototype]]에 대한 getter 함수라고 하며, 표준이 아니다. 

프로토타입 객체는 다른 프로토타입 객체의 링크를 가지며, ```Object()```이 프로토타입 객체 처럼 최상위에 있는 객체의 내부 프로토타입 링크가 null이다. 이 것을 가르켜 "프로토타입 체인"이라고 한다.  

{% asset_img proto2.png "new object" %}

### 4.1.8. 객체 내의 속성 탐색 순서
위에서 처럼 new 로 객체가 된 후 그 객체의 속성 중 하나에 접근하면, 프로토타입 체인을 따라가면서 해당 속성이 있는지 검사를 하게 된다. 이 방법으로 프로토타입 객체는 공유 객체가 되는 것이며, 이미 new로 만들어진 객체라 하더라도 프로토타입 객체에 동적으로 추가한 함수나 변수를 사용할 수 있는 것이다.

### "for-in을 사용하면 프로토타입 객체에 있는 속성까지 모두 순회 한다."
위와 같은 이유로 때문에 for 문 내에 ```hasOwnProperty()``` 함수를 사용한다. 이 함수는 특정 속성이 객체 자신의 속성인지 아닌지를 검사해 준다. 

{%codeblock "" lang:javascript%}
for (prop in foo) {
    // 객체의 
    if(foo.hasOwnProperty(prop)) {
        // ...
    }
}
{%endcodeblock%}

 
### 4.1.9. 프로토타입의 장단점

프로토타입은 결국 여러 객체 들이 공유하는 것이며, 프로토타입을 사용하지 않고도 객체 내부에 모두 구현이 가능하다. 객체가 많을 경우에는 **"메모리 낭비"** 가 생기게 된다. 

하지만, 프로토타입의 사용은 **"탐색 시간의 증가"**를 초래하게 된다. 한두번이야 상관없겠지만, 접근 횟수가 많을 경우에는 많은 시간이 걸릴 수 있다.


## 4.2. 자바스크립트에서의 상속 활용

자바스크립트의 프로토타입을 활용하여 다른 언어처럼 "상속" 구현하기 위한 방법에는 여러가지가 있다. 기존 방법(?)의 문제점과 새로운 방식이 책에서 소개된다.

### 4.2.1. 기존 상속 구현 방법

#### 초창기 자바스크립트의 상속 구현 방법
초창기 자바스크립트의 상속 구현 방법은 부모 함수 객체에 자식 함수 객체에 필요한 속성만 추가 하여 리턴하는 방식이었다. 하지만 instanceof가 제대로 동작하지 않는 문제가 있었다.
{%codeblock "" lang:javascript%}
function Parent() {
  this.name = "parent";
}

function Child() {
  var obj = new Parent();
  this.name = "Child";
  return obj;
}

var child = new Child();
// instanceof가 제대로 동작하지 않는 문제가 있다.
console.log(child instanceof Child); // false
console.log(child instanceof Parent); // true
{%endcodeblock%}

#### 조금 개선된 상속 구현 방법

다음 코드와 같이 자식 함수의 프로토타입 객체를 Parent()로 생성된 객체로 넣으면 ```instanceof``` 가 제대로 동작한다. 그러나 ```constructor```의 링크가 깨지는 문제가 발생한다.

{%codeblock "" lang:javascript%}
function Parent() {
  this.name = "parent";
}

function Child() {
  this.name = "Child";
}

// 이렇게 생성된 Parent 객체를 Child의 prototype 객체로 만드는 방식이었다. 
Child.prototype = new Parent();

// 마침내 instanceof 가 잘 동작한다.
var child = new Child();
console.log(child instanceof Child); // true
console.log(child instanceof Parent); // true

// 하지만 생성자 함수가 Parent()로 바뀌는 문제가 존재한다..
console.log(child.constructor); // function Parent()
{%endcodeblock%}



내부의 링크가 깨진다던지 하는 문제가 발생한다. 또한 ```new``` 키워드 자체가 자바스크립트 답지 않다는 주장이 많이 반영되어 ```Object.create``` 함수를 만들어 내게 된다.

### 4.2.2. instanceof 동작 원리
이 책에서는 길게 설명하고 있지만, 구글링을 통해 찾은 것은 간단하다. 좌측 객체의 포로토타입이 우측 객체의 프로토타입 체인에 속해 있는지 검색해보는 것이다.

### 4.2.3. Object.create 함수
 
IE9 이상부터 지원되는 함수이며, 더글라스 크락포드가 주장한 이 함수의 기본 형태는 다음과 같다.

{%codeblock "" lang:javascript%}
Object.create = function(o) {
    function F() {}
    F.prototype = o;
    return new F();
}
{%endcodeblock%}

```o```를 통해서 생성할 객체의 prototype을 받아서 새로 만든 함수의 prototype으로 설정한다. 

### 4.2.6. Object.create와 new 키워드의 조합
둘의 조합으로 드디어 원하는 상속이 가능하게 된다.

{%codeblock "" lang:javascript%}
function Parent() {
  this.name = "parent";
}

function Child() {
  this.name = "Child";
}

// Child 함수 객체의 prototype 을 직접 만들어 준다.
// 리턴된 함수는 constructor 속성으로 Child 함수를 가지고,
// prototype 속성으로 Parent 함수의 prototype을 가진다.
Child.prototype = Object.create(Parent.prototype, {
  constructor: {
    value: Child
  }
});

// 마침내 instanceof 가 잘 동작한다.
var child = new Child();
console.log(child instanceof Child); // true
console.log(child instanceof Parent); // true

// 생성자 함수도 잘 연결되어 있다.
console.log(child.constructor); // function Child()
{%endcodeblock%}
