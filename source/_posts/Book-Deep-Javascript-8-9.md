---
layout: blog
title: '[Book Summary] 속깊은 Javascript 8/9'
date: 2017-06-29 18:35:15
categories:
- Book Summary
tags:
- javascript
---

{% asset_img cover.jpg%}
 
# Chapter 8. Javascript 코딩과 개발 환경

## 8.1. 자바스크립트 코딩 스타일

### 8.1.1. 변수 이름 표기법
Javascript에서는 camel case 표기법이 좋다. ```getElementById``` 처럼 DOM을 다루는 API들이 이미 채택하고 있기 때문이다. 여기에 다음과 같이 변수 타입을 나타내는 헝가리안 표기법을 더하는 것도 좋다.
{%codeblock "camel case + hungarian" lang:javascript%}
var nFirstVariable = 0;
var strSecondVariable = "";
var arrSomeLongVariableName = [];
var g_nGlobalVariable;
{%endcodeblock%}

### 8.1.2. 공백과 탭
공백을 선호하는 추세로 바뀌고 있으나, 탭은 1바이트라는 장점을 가지고 있다. 이 책에서는 4칸이 가독성이 더 좋다고 하지만, depth가 깊어지면 보기가 어려워 진다는 것이 나의 의견. 

### 8.1.3. 중괄호를 여는 위치
중괄호는 줄바꿈하지 않는 것이 좋고, 줄바꿈을 한다면 오동작을 주의해야 한다. Javascript는 세미콜론 사용에 대한 규칙을 느슨하게 적용하는데, ```return``` 다음 줄에 결과를 주더라도 ```return;```으로 만들어 버리기 때문이다. 

### 8.1.4. strict mode
ECMAScript 5가 권장하는 방법이다. ```"use strict"```파일이나 함수에 추가함으로서 설정 가능하다. strict 모드에서 제한 되는 내용은 다음과 같다.

#### "scope 내부에서 var 없이 global 변수를 선언할 수 없다."
책에서의 설명은 "var 없이 변수를 사용할때 레퍼런스 오류 발생"이라고 하는데 맞기도 하고 틀리기도 한 말이다. strict mode에서는 글로벌 변수를 선언할때도 var를 붙어야만 하기 때문이다. 하지만 아래와 같은 코드일 경우, global에 이미 선언되어 있으면 에러가 발생하지 않는다. 이 것은 delete가 변수에 동작하지 않는 것과도 연관이 있다. 
{%codeblock "" lang:javascript%}
"use strict";
(function() {
    globalVar = "This will be global"; 
    // 에러! 단, 이미 해당 글로벌 변수가 선언되어 있으면 에러 발생하지 않음.
}());
{%endcodeblock%}

#### "delete를 변수나 함수에 사용할 수 없다." 
원래 객체의 속성을 지우는 기능이이라고 생각하면 쉽다. 그러나, ```delete```에는 좀 더 깊은 내용이 숨어 있다. ```var a = 1;``` 와 ```window.a = 1;```은 같은 글로벌 변수인데다가 결국 window객체의 속성 값인   ```a```가 셋팅 되는 것이지만, ```delete```의 가능 여부가 다르기 때문에 분명한 차이가 있다. hoisted와도 연관이 있다. [Stack overflow]("https://stackoverflow.com/questions/1596782/how-to-unset-a-javascript-variable")를 보고 나중에 보고 조금 더 정리 예정.
{%codeblock "" lang:javascript%}
"use strict";
var a = 1;
delete a; // 에러!
{%endcodeblock%}  
  
#### "변수에 eval과 arguments를 이름으로 사용할 수 없다."
이 것은 "좀 더 명료한 코드를 위해서"인 것으로 보인다.
{%codeblock "" lang:javascript%}
"use strict";
var arguments = 1; // 에러!
var eval = 1; // 이것도 에러!
{%endcodeblock%}    

### "eval()함수 안에서 변수를 선언이 불가하다.(??)"
이건 책이 명백히 틀렸다고 보여지는 내용이다. 에러 발생하지 않는다. 단지 주변 스코프에 영향의 주는지의 차이가 있음. 

- 일반모드 : 실행 컨텍스트에 영향을 줌. 
{%codeblock "" lang:javascript%}
var a = 1;
console.log(eval("var a=42;a")); // 42
console.log(a); // 42
{%endcodeblock%}

- strict 모드 : 실행 컨텍스트에 영향을 주지 않음. 새로운 스코프가 생기는 것처럼 보인다 (불명확함.)
{%codeblock "" lang:javascript%}
"use strict";
var a = 1;
console.log(eval("var a=42;a")); // 42
console.log(a); // 1
{%endcodeblock%}

### "같은 이름의 파라미터 두개 이상 사용할 수 없다."
- 일반 모드 : 파라미터가 같으면 마지막 파라미터를 해당 변수명으로 인식한다.
{%codeblock "" lang:javascript%}
function foo(a,a) {
    console.log(a); 
}
foo(1,2); // 2
{%endcodeblock%}

- strict 모드 : 파라미터가 같으면 문법 에러를 발생시킨다.
{%codeblock "" lang:javascript%}
"use strict";
function foo(a,a) { // 에러!
    console.log(a); 
}
{%endcodeblock%}

### "arguments.caller, arguments.callee 에 접근할 수 없다."

caller는 사라진 속성인 것 같고, callee를 strict 모드에서 접근하면 에러가 발생한다.
- 일반 모드 : foo()와 함수 코드 출력.
{%codeblock "" lang:javascript%}
"use strict";
function foo() {
    console.log(arguments.callee); // foo() {...}; 
}
foo();
{%endcodeblock%}

- strict 모드 : callee에 접근하면 에러를 발생 시킨다.
{%codeblock "" lang:javascript%}
"use strict";
function foo() {
    console.log(arguments.callee); // 에러! 
}
foo();
{%endcodeblock%}

### "with 구문을 사용할 수 없다."
앞장에서 본 모호함 때문인지, strict 모드에서는 사용 금지다.

## 8.2. 자바스크립트 검증 도구 - JSLint

자바스크립트의 코드 검증 도구이다. 권장하는 방법과 모호한 표현을 잡아내고, 불필요한 공백까지도 경고를 출력한다. 예를 들어서 for in 내부에서 속성를 검사할 때 ```hasOwnProperty()```를 사용하여 걸러 내는 것이 매우 중요하다. 그렇지 않으면, 프로토타입 체인에 있는 속성까지도 사용하게 되어 의도치 않은 결과가 나온다ㅏ. 여러 IDE에 대해서 JSLint 플러그인이 존재한다. 자세한 규칙에 관해서는 [JSLint]("http://www.jslint.com/help.html")를 참고하면 된다.

## 8.3. 자바스크립트 빌드 환경

 배포와 빌드에 관한 내용이다. Google Closure를 사용할 때의 설정과 실행방법에 대한 설명이다. 압축을 하거나, git에 hook 스크립트를 집어 넣거나, makefile을 만드는 것에 대한 설명이다.