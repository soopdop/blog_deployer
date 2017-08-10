---
title: '[Book Summary] 속깊은 Javascript 2/9'
date: 2017-06-26 15:10:24
categories:
- programming
tags:
- javascript, Book Summary
---

{% asset_img cover.jpg%} 

# Chapter 2. 자바스크립트의 스코프와 클로저

## 2.1. 스코프란?
다른 프로그래밍 언어를 다루다가 자바 스크립트를 접하게 된 프로그래머가 반드시 한번 빠지게 되는 함정. 
{% blockquote %}
자바 스크립트는 일반적인 프로그래밍 언어의 블록 스코프를 따르지 않는다. 
{% endblockquote %}

### 2.1.1. 스코프의 생성

자바 스크립트에서 스코프를 생성하는 구문은 세가지가 있다.

#### function을 이용한 스코프 생성
foo() 내부에서 선언된 변수를 외부에서 접근할 수 없다. 
{% codeblock "function을 이용한 scope 생성" lang:javascript%}
function foo() {
    var b = "Can you access me?";
}
console.log(type of b); //"undefined"
{% endcodeblock %}

#### catch을 이용한 스코프 생성

catch의 인자(이 경우에는 err)만 내부 스코프에 포함 된다. 선언된 변수(이 경우에는 test)는 외부 스코프에 포함된다. 

{% codeblock "catch를 이용한 scope 생성" lang:javascript%}
try {
    throw new exception("fake exception");
} catch (err) {
    var test = "can you see me?";
}
console.log(type of err); // "undefined"
console.log(test); // "can you see me?"
{% endcodeblock %}

#### with을 이용한 스코프 생성

with 구문도 catch 처럼 인자가 내부 스코프에 포함 된다. 

{% codeblock "with를 이용한 scope 생성" lang:javascript%}
with({A: "You can't see me"}) {
    var B = "but you can see me";
    console.log(A); // "You can't see me"
    console.log(B); // "but you can see me"
}
console.log(B); // "but you can see me"
console.log(A); // error!!
{% endcodeblock %}

### 2.1.2. 스코프의 지속성

다른 언어와 다른 JavaScript 만의 강점 중 하나는, 스코프가 지속 된다는 점이다. 함수가 선언된 곳이 아닌 전혀 다른 곳에서 함수가 호출될 수 있어서, 해당 함수가 참조하는 스코프를 지속할 필요가 있다.

### 2.1.3. with 구문
with 구문은 파라미터로 받은 객체를 스코프 체인에 추가하여 동작한다. 즉, 해당 오브젝트는 블록 안에서 사용되는 변수에 대한 탐색의 대상이 되는 상위 스코프로 추가되는 것이다.

{% codeblock "with 의 기본 사용법" lang:javascript%}
var user = {
    name : "sd",
    age : "20"
}

with(user) {
    console.log(name, age); // sd 20
}
{% endcodeblock %}



### 2.1.4. with를 사용하지 말아야하는 이유

#### 첫번째, with를 사용한 코드는 모호성을 가진다.

다음 소스에서 value가 인자의 value인지, obj.value를 의도한 것인지 모호하다.

{% codeblock "with 구문의 모호성" lang:javascript%}
function something(value, obj) {
    with(obj) {
        console.log(value); // value?? obj.value??
    }
}
{% endcodeblock %}

#### 두번째, with는 표준에서의 제외된다.
위와 같음 모호성으로 인하여 with문 사용을 자제 하라고 권하고 있으며, ECMAScript 6에서는 deprecated될 예정이다.

#### 세번째, with의 대상 객체는 속성을 추가 할 수 없다.
with에 style 객체를 사용할 경우, 새로운 속성을 추가할 수 없다.

{% codeblock "style 추가 불가" lang:javascript%}
with (document.getElementById("myDiv").style) {
    background = "yellow"; // 이미 존재하는 속성인 경우 OK.
    border = "1px soild black"; // border 속성을 새로 추가하려고 의도한 경우, global 변수로 선언되어 버린다.
}
{% endcodeblock %}


## 2.2. 클로저란?
이 책에서는 클로저를 다음과 같이 정의한다.
> "특정 함수가 참조하는 변수들이 선언된 lexical scope는 계속 유지되는데, 그 함수와 스코프를 묶어서 클로저라고 한다."

사실 좀 와닿지 않고, 이해하기 어렵다. 그래서 다른 곳에서 정의를 찾아 보았다. [MDN 문서](https://developer.mozilla.org/ko/docs/Web/JavaScript/Guide/Closures)는 다음과 같이 정의한다. 
> "클로저는 독립적인 (자유) 변수 (지역적으로 사용되지만, 둘러싼 범위 안에서 정의된 변수)를 참조하는 함수들이다. 다른 말로 하면, 이 함수들은 그들이 생성된 환경을 '기억'한다."

쉽게 말해서, 클로저는 함수와 함수가 선언된 문법적 환경의 조합이라 할 수 있다.  

{% codeblock "가장 간단한 closure 예제" lang:javascript%}
function counterGenerator() {
    var count = 0;
    return function() {
        return ++count;
    }
}

var counterA = counterGenerator();
var counterB = counterGenerator();

console.log(counterA()); // 1;
console.log(counterA()); // 2;
console.log(counterB()); // 1;
console.log(counterB()); // 2;
{% endcodeblock %}

위의 예제에서 count 변수의 참조는 리턴된 익명함수 내에서 계속 유지된다. 즉 count 값을 증가 시킬 수 있고, 리턴 받아서 출력해볼 수도 있다.

### 2.2.1. 클로저 쉽게 이해하기

#### [개인적인 조사] 새로운 스코프는 "선언" 시에 생성 되는 것인가? "실행" 시에 생성되는 것인가?
Javascript는 Lexical Scope를 이용한다. 이 것의 의미를 정확하게 파악할 필요가 있다. 자세한 것은 ["You don't know JS"](https://github.com/getify/You-Dont-Know-JS)를 참고하고, 번역판도 훑어볼 예정.

##### a. Lexing
전통적인 컴파일러는 다음의 세가지 과정을 거쳐 코드를 실행가능한 코드로 바꾼다. **lexing -> parsing -> code-generation**. Lexing이란 string으로 되어있는 코드를 의미 있는 단위로 tokenizing하는 것을 뜻한다. 

##### b. Lexical Scope
lexical scope라는 것은 lex-time에 정의되는 Scope를 뜻한다. lex-time이란 위에서 말한 lexing 과정을 말하는 것이다. 즉, 어떤 모양의 Scope chain을 가질지 이 때 결정되는 것이다. static scope와 같은 말이며, 반대 되는 개념으로는 dynamic scope가 있다. 
 
##### c. Scope Chain
엔진이 코드를 실행 시, 어디서 변수를 찾을지를 말해주는 정보이다. ["You don't know JS"](https://github.com/getify/You-Dont-Know-JS)에 따르면, 변수를 어디에 저장하고 어디서 찾을 것인가에 대한 룰의 집합이라고 한다.   

Javascript는 function기반으로 scope를 생성하므로, global scope 를 base로 하여 function과 nested function이 선언될 때마다 하위 Scope를 만들게 된다. 즉, 다음의 코드에서 scope는 3단계가 되며, ```console.log```에서 변수 ```a```를 찾기 위해서 3번의 탐색을 거치게 된다. 
1. global scope
1. foo() scope
1. bar() scope

{% codeblock "가장 간단한 closure 예제" lang:javascript%}
var a = 1;
function foo(b) {
	var c = b * 2;
	function bar(d) {
		console.log(a, b, c, d);
		debugger;
	}
	bar(c * 3);
}
foo( 2 ); // 1 2 4 12
{% endcodeblock %}

scope는 chrome devtools에서 확인할 수 있다. ```debugger``` 키워드를 이용해서 함수 내에서 실행을 중단 시킨 후 다음과 같이 scope 항목에서 확인이 가능하다. 

{% asset_img debugger_scope.png "Debugger and Scope" %}

##### d. Dynamic Scope과의 차이
Shell Script나 Perl은 dynamic scope 방식을 사용한다. 신기하게도 다음과 같이 같은 소스로 static과 dynamic scope를 둘다 테스트 해 볼 수 있다.

{% codeblock "Static Scope vs Dynamic Scope" %}
$ ksh -c 'function f1 { typeset a=local; f2; echo $a; };
  function f2 { echo $a; a=changed; };
  a=global; f1; echo $a'
global
local
changed

$ bash --posix -c 'function f1 { typeset a=local; f2; echo $a; };
  function f2 { echo $a; a=changed; };
  a=global; f1; echo $a'
local
changed
global
{% endcodeblock %}

위의 소스에서 아래 bash로 실행한 코드가 dynamic scoping을 따른다. 요약하자면, static scoping을 기반으로 생각할 때는 ```f1```과 ```f2``` 함수는 별개로 선언되어 있으므로, ```f2```에서 참조하는 ```a```는 당연히 global에 선언된 a이어야 한다. 하지만, 실행해 보면 f1의 a를 참조하고 있다는 것을 알 수 있다. 
 
 결론적으로, "Dynamic scoping"은 변수를 탐색할 때, 실제 call이 되는 순서를 기준으로 탐색한다. **즉, call stack을 기준으로 찾는다.** 

[Stack Overflow 답변](https://stackoverflow.com/questions/1047454/what-is-lexical-scope)에서도 다음과 같은 C스타일의 코드를 통해서 Dynamic scope를 설명한다.

      
{% codeblock "Dynamic Scope" lang:c%}
void fun()
{
    printf("%d", x);
}

void dummy1()
{
    int x = 5;
    fun();
}

void dummy2()
{
    int x = 10;
    fun();
}
{% endcodeblock %}

```dummy1()```과 ```dummy2()``` 내부에서 호출되는 ```fun()```은 x를 가지고 있지 않으며, 외부 scope를 탐색하게 되는데 각각의 call stack을 따라 탐색을 하면 5와 10이 출력될 것이다. static scope라면 ```fun()```에서 x를 찾을 수 없으므로 위의 문법은 static scope를 사용하는 C언어에서 틀린 문법이다.       
      
##### e. 결론
코드를 작성 할 때 그 것의 이미 scope가 정해진다. 이 시점을 author-time이라 한다. 실제적으로는, 컴파일러의 lexing 단계, 즉 lex-time에서 scope가 정해진다. 이러한 이유로 이벤트 핸들러를 ```for``` 문 내에서 설정할 때, ```i```를 사용할 경우, 각각 다른 scope와 값을 가진 i가 아닌, 글로벌 변수 i 하나만을 참조하는 것이다.  반대로, dynamic scope의 경우에는 call stack에 따라 바뀌므로 run-time에 결정된다. 

단, scope와 scope chain 정보가 어디에 있으며([[scope]], variableObject, excution context가 뭔지..), 언제 생성되어 그 곳에  어떻게 메모리에 구성되는지 좀더 조사 해야 함.

### 2.2.2. 클로저의 실제 활용의 예

#### 클로저를 만드는 방법 1 - 내부 함수를 리턴하여 사용 한다. 
{% codeblock "static, local 변수를 가진 카운터" lang:javascript%}
var counterFactory = function(){
    var staticCount = 0; 
    return function () {
        var localCount = 0;
        return {
            inc : function() {
                return {
                    static: ++staticCount,
                    local: ++localCount
                }        
            }
        }
    }
}(); 

var counterA = counterFactory();
console.log(counterA.inc()); // Object {static: 1, local: 1}
console.log(counterA.inc()); // Object {static: 2, local: 2}
var counterB = counterFactory();
console.log(counterB.inc()); // Object {static: 3, local: 1}
console.log(counterB.inc()); // Object {static: 4, local: 2}
{% endcodeblock %}

이 때, **IIFE(Immediate Invoke Function Expression)** 패턴을 사용하게 되는데, IIFE 내부에 함수를 구현하여 리턴한다. IIFE를 사용하는 이유는 클로저를 생성하기 위해서이고 (이 경우에는 staticCount를 유지하고 참조하기 위해서),  실제 동작하는 루틴은 리턴하는 함수 안에 안에 들어 있다.

#### 클로저를 만드는 방법 2 - 내부 함수를 콜백으로 등록하여 사용한다.

{% codeblock "setTimeout event handler 등록" lang:javascript%}
(function(){
    var count = 0;
    var interval = false;
    
    function handler () {
        console.log(++count);
        if(count >= 10) {
            clearInterval(interval);
            count = 0;
        }
    }
    interval = setInterval(handler, 1000);
}());
{% endcodeblock %}


### 2.2.3. 클로저의 단점
클로저는 다음과 같은 단점이 있으나, 꼭 필요한 경우에는 사용하는 것이 좋다.
1. 클로저는 메모리를 소모한다.
2. 과하게 사용하면 변수의 탐색 시간으로 인해 성능에 영향을 준다.