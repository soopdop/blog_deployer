---
title: '[Book] 속 깊은 Javascript 3/9'
date: 2017-06-27 15:57:44
categories:
- Book Summary
tags:
- javascript
---

# Chapter 3. 자바 스크립트의 변수

## 3.1. 자바스크립트의 기본 형과 typeof

### (1) javascript의 기본형
객체가 아닌 기본적인 키워드로 활용할 수 있는 기본형. 
- number
- string
- boolean
- undefined
- null
- symbol

### (2) typeof의 결과 목록
typeof는 문자열을 반환한다.
- "undefined"
- "boolean"
- "number"
- "string"
- "object"
- "function"
- "symbol"

### (2) typeof의 결과 중 특이 한 것
**"typeof null은 object이다."** 따라서, typeof를 이용해서 object인지 체크한 뒤 어떤 동작을 추가하려면, null 체크를 따로 먼저 해주는 것이 좋다.
{% codeblock "object vs function" lang:javascript%}
if(aaa !== null && typeof aaa === "object") {
    // do something with aaa
}
{% endcodeblock %}

## 3.2. new String("")과 ""과 String("")의 차이
Javascript의 문자열은 기본형(primitive)과 객체형 두가지 형태로 존재한다. 

### (1) new String()은 래퍼객체이고, ""과 String("")은 기본형이다.

String("")은 표준에 정의된 일련의 과정을 통해서 결국 기본형을 리턴한다. 

{% codeblock "new String('') vs '' vs String('')" lang:javascript%}
console.log(typeof new String("abc")); //object
console.log(typeof String("abc")); // string
console.log(typeof "abc"); // string
console.log("abc" === String("abc")); // true
{% endcodeblock %}

### (2) 기본형은 레퍼객체나 Object의 인스턴스가 아니다.

{% codeblock "instanceof primitive type" lang:javascript%}
console.log(123 instanceof Number); // false
console.log(123 instanceof Object); // false
console.log(new Number(123) instanceof Number); // true
console.log(new Number(123) instanceof Object); // true
console.log("123" instanceof Number); // false
console.log("123" instanceof Object); // false
console.log(new String("123") instanceof String); // true
console.log(new String("123") instanceof Object); // true
{% endcodeblock %}


### (4) 기본형에는 속성을 추가할 수 없다.
정확히 말하자면, 기본형의 프로퍼티 접근시 내부적으로 new String("")으로 레퍼객체를 만들었다가 바로 사라지기 때문인데, 이 책에서는 그러한 설명이 없다. 설명은 이곳 : [래퍼 객체](http://noritersand.tistory.com/536)

{% codeblock "래퍼 객체" lang:javascript%}
var test = "test";
console.log(test.length); // new String(test).length와 같다.
test.abc = "abc"; // new String(test).abc = "abc"와 같다.
console.log(test.abc) // undefined 있을리 없음.
{% endcodeblock %}

### (5) String.prototype에 함수를 추가하면 기본형에서도 쓸 수 있다.
이 또한 프로퍼티 접근시 래퍼 객체를 생성해서 호출하기 때문에 가능한 것이다.

{% codeblock "String.prototype에 함수 추가" lang:javascript%}
String.prototype.getLength = function () {
    return this.length;
}
var test = "test";
console.log(test.getLength()); // new String(test).getLength()와 같다.
{% endcodeblock %}

## 3.3. 글로벌 변수
많은 자바스크립트 개발자가 글로벌 변수를 사용한다. 아무 생각 없이 변수를 사용했다면 글로벌 변수이다.

### 글로벌 변수를 자제 해야 하는 이유

- 소스를 나눠서 관리할 때 각 소스 끼리 충돌 발생 가능성. 
    - 예: xhr = new XMLHttpRequest()가 여러 소스에 있을 경우
- 서버의 응답을 기다리는 등의 비동기식 처리 시 문제 발생 가능성.
    - 예: xhr을 공유하거나 겹치게 사용하는 경우, 여러 곳에서 다른 xhr.onreadystatechange를 등록하게 되고, 응답이 오기전에 두 번 이상의 요청을 보낸 경우 앞의 응답이 온 것에 대해서 처리하지 못하게 된다.
- 메모리 관리 차원에서
    - 변수들의 레퍼런스 카운터가 0가 되지 않는 이상 가비지 컬렉터가 메모리를 해제하지 않으므로, 잠시 사용할 변수는 로컬 변수로 선언하는 것이 옳다. 

## 3.4. 글로벌 변수 정의

### 글로벌 변수 정의 방법

1. ```<script>``` 안에 ```var``` 로 선언한다.
1. 모든 곳에서 ```var``` 없이 선언한다.
    - 단, 이 경우 상위 scope를 탐색 해 본 후 없으면 글로벌 변수가 된다.
1. ```for```문에서 ```i```를 잘못 사용하면 오동작의 원인이 된다.

## 3.5. Window 객체
글로벌 영역을 관장하는 "The Global Object"이다. 이 객체는 브라우저가 제공하며 약간 특수한 성질을 가지고 있다. 
- new 로 생성할 수 없다.
- 함수로 호출할 수 없다.
- 프로토타입이 없다.

#### "window는 window.window.window이다."
window는 재귀적인 형태를 가지고 있다. 
{% codeblock "window.window" lang:javascript%}
console.log(window === window.window); // true
{% endcodeblock %}

#### "글로벌 변수에 프로퍼티로 접근이 가능하다."
{% codeblock "the way to access global variables" lang:javascript%}
var a = 1;
console.log(window.a); // 1
{% endcodeblock %}

#### "글로벌 변수에 이름으로 접근도 가능하다."
{% codeblock "the way to access global variables" lang:javascript%}
var a1 = 1;
var a2 = 2;
var i = 0;
console.log(window["a" + ++i]); // 1
console.log(window["a" + ++i]); // 2
{% endcodeblock %}

#### "글로벌 함수 호출도 같은 방법으로 가능하다."
{% codeblock "the way to call global functions" lang:javascript%}
function foo() {
    return "foo";
}
console.log(window["foo"]()); // foo
{% endcodeblock %}

## 3.6. 글로벌 변수 선언 방법과 차이
글로벌 변수를 선언하는데는 몇가지 방법이 있다.

1. 글로벌 스코프에서 var 키워드를 이용한 선언.
1. 특정 스코프에서 상위 스코프에 선언되지 않은 변수를 var 선언.
1. window 객체에 속성 추가.

### "Hoisting"
이 책에서 사용한 용어는 아니지만, 자바스크립트는 변수와 함수의 선언을 hoisting(끌어올림) 한다. 즉, 아래 쪽에 선언한 변수와 함수를 위에서 접근할 수 있다는 뜻이다.

{% codeblock "Hoisting" lang:javascript%}
foo();

function foo() {
    console.log(bar); // undefined
    bar = "bar"; // 지역 변수의 할당, 전역 변수의 선언이 아니다.
    console.log(bar); // bar
    var bar; // declaration here.
}

console.log(bar); // error!
{% endcodeblock %}

## 3.7. var 키워드의 효율적인 사용
JSLint는 항상 다음을 권하는 메세지를 출력한다. 
{% blockquote %}
    모든 변수는 함수의 위쪽에 묶어서 선언한다다.
{% endblockquote %}

이렇게 하는 것에는 몇가지 이유가 있다.

### (1) 초기화 실수의 최소화
이 책에 나오는 이유는 그다지 명확하지가 않다. 내 생각은 다음과 같다. "선언되지 않은 변수"와 "초기화 되지 않은 변수"는 모두 ```typeof```의 결과로 ```undefined```를 리턴한다. 우리는 때로 이것을 구분해야할 필요가 있다. 소스가 길어지면 "어딘가"에 선언되어 있을지도 모르는 변수를 재선언을 하는 등의 문제를 만들 수 있기 때문이다.

### (2) 변수 관리 차원
책보다 설명을 잘 할 수 있을 듯 하다. Javascript는 nested 함수를 지원하는데, 변수를 var 없이 할당하면 글로벌 변수가 만들어 지거나 이전 스코프의 변수를 변경하게 된다. 게다가 hoisting까지 지원하기 때문에 변수를 잘 관리 하지 않으면 버그를 만들어 내기 매우 쉬운 환경이다. 따라서 모든 함수의 도입부에 로컬 변수를 잘 선언해 이러한 혼란을 막는데 도움을 줄 수 있다.

### (3) Minifying
minifying할 때 더 잘 줄일 수 있다 한다.

## 3.8. 글로벌 변수 최소화하기
다음과 같은 두가지 방법으로 글로벌 변수를 회피할 수 있다.
1. 클로저 사용하기
1. 모듈/네임스페이스 패턴 사용하기
    - Jquery의 $처럼, window.$에 모든 것을 넣어 모듈 처럼 이용하는 방법

## 3.9. 변수 사용 방법과 성능
**외부 스코프의 변수를 그대로 사용하는 것이 아니라, 지역변수로 한번 참조한 뒤 그 지역변수를 사용하는 것이 성능에 도움이 된다.** 현재의 스코프에 어떤 변수가 없을 때마다, 재귀적으로 상위 스코프로 탐색을 실시하게 되기 때문이다.  
