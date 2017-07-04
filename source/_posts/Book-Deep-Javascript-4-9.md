---
layout: blog
title: '[Book Summary] 속 깊은 Javascript 4/9'
date: 2017-06-29 14:35:43
categories:
- Book Summary
tags:
- javascript
---

{% asset_img cover.jpg%} 

# Chapter 4. 프로토타입과 객체지향, 그리고 상속

## 4.1. 프로토타입을 통한 객체지향

### 4.1.1. 프로토타입의 정의
Javascript가 제공하는 객체 지향을 지원하기 위한 방법

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
자바스크립트에서의 ```this```가 무엇인지는 함수나 스코프 기반이 아닌 **"호출 방법"**에 따라서 변경이 된다.
{%codeblock "this in javascript" lang:javascript%}
function Person(name, blog) {
    this.name = name;
    this.blog = blog;
}
{%endcodeblock%}

#### 일반 함수 내에서의 this
Window 객체이다.
{%codeblock lang:javascript%}
function foo() {
    console.log(this);
}

foo(); // Window {...}
{%endcodeblock%}

#### 맴버 함수 내에서의 this
해당 함수를 포함하는 객체이다.
{%codeblock lang:javascript%}
var obj = {
    foo : function () {
        console.log(this);
    }
}
obj.foo(); // Object {...}
{%endcodeblock%}

#### call()과 apply()로 호출한 함수 내에서의 this
```call```과 ```apply```를 이용하여 함수를 호출하면, 해당 함수 내에서의 this를 바꿀 수 있다. 
{%codeblock lang:javascript%}
function foo() {
    console.log(this, this.bar);
}
var obj = {
    bar : "bar"
};
foo.call(obj); // bar
{%endcodeblock%}
- 위와 같이 ```obj```객체를 파라미터로 넘겨주어 ```foo``` 함수의 실행 컨텍스트를 바꿀 수 있다. 
- ```call```의 파라미터가 없거나, 파라미터로 ```undefined```나 ```null``` 을 주면 함수 내부에서의 ```this```는 Window 객체를 가르킨다.
- 일반적으로 함수를 호출할 경우 내부적으로 ```call```을 파라미터 없이 호출하게 되고, 그 때의 ```this```는 ```Window``` 객체를 가르키게 된다고 한다.
- ```call```과 ```apply```의 차이는 파라미터를 객체로 줄수 있는지의 차이이다.

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

하지만, ```new Person("my name","my blog")``` 으로 호출 함으로써 내부적으로 다음의 절차를 따르게 된다. 책의 설명이 이해가 안되서 직접 찾아 봄. [참고: ecma-internal](http://www.ecma-international.org/ecma-262/5.1/#sec-11.2.2)
1. new는 몇가지 체크 후, 내부 함수인 [[Construct]]를 호출한다.
1. [[Construct]]는 다음의 절차를 따른다.
    1. 새로운 object인 obj생성한다.
    1. 파라미터인 함수 F의 prototype을 obj에 설정한다.
    1. F의 내부 함수인 [[Call]]을 호출 하는데, 이때 obj와 파라미터를 넘겨 obj를 초기화 시킨다. (예제에서의 obj.name와 obj.blog가 셋팅되는 과정으로 보임)
    1. obj를 리턴한다.

### 4.1.5. 프로토타입에 대한 표준 정의
prototype은 다른 객체들과 공유되는 속성을 제공하는 객체이다. 생성자 (함수)가 객체 생성 시 생성자의 prototype를 참조하며, 이렇게 생성된 객체와 상속된 객체도 같은 prototype 객체를 공유한다.   
 
### 4.1.6. 프로토타입의 사용 예


### 4.1.7. 프로토타입과 생성자

### 4.1.8. 객체 내의 속성 탐색 순서
 
### 4.1.9. 프로토타입의 장단점

