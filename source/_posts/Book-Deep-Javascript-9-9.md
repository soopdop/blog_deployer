---
layout: blog
title: '[Book Summary] 속깊은 Javascript 9/9'
date: 2017-06-29 18:35:38
categories:
- Book Summary
tags:
- javascript
---

{% asset_img cover.jpg%} 

# Chapter 9. 자바스크립트 표준

## 9.1. ECMAScript 6 표준

2015년 6월에 발표된 ECMAScript 6(ES6)은 ECMAScript 2015라고도 불린다. ES6과 ES 2015가 같기 때문에 조금 헷갈린다. 기존의 표준에 추가적인 기능들과 조금 더 나은 프로그래밍 언어의 모습을 얹어 놓았다. 개인적으로는 vue.js 2를 이용해서 개발할때 필요하므로 자세히 정리한다.
  

### 9.1.1. 변수, 상수 선언 키워드(let, const)

#### "const는 이전에 없었던 '상수'를 선언하는 기능이다."
같은 변수를 const로 선언 후 다시 정의 하면 에러가 발생한다. 

{%codeblock "" lang:javascript%}
const a = 1;
a = 2; // 에러! 상수 변경 불가.
{%endcodeblock%}

#### "let은 "변수"를 선언하는데 var와는 조금 다르다."
var 와 다른 점은 다음 두가지이다.
1. 중복 선언이 불가능하다.
1. 다른 언어 처럼 중괄호를 이용한 블록 개념을 가지고 있다.

{%codeblock "" lang:javascript%}
const a = 1;
a = 2; // 에러! 상수 변경 불가.

let b = 1;
let b = 2; //에러! 중복 선언 불가.

for (let i = 0; i < 10; i++) {}
console.log(i) // 에러! i는 이미 사라짐.
{%endcodeblock%}

### 9.1.2. 함수 화살표 표현식
ES6에서는 익명 함수를 표현할 때 간단히 표현할 수 있는 화살표 표현식이 추가되었다.

#### "화살표 표현식이 생겼다."
{%codeblock "" lang:javascript%}
let func;
func = function (msg) {alert(msg);}
func = (msg) => alert(msg);  // 이 둘은 동일하다.
{%endcodeblock%}

#### "콜백 함수에서의 this가 달라졌다."
기존의 익명함수는 ```setTimeout```에 넘긴 익명함수의 컨텍스트가 global이었으나, 화살표 표현식을 통한 컨텍스트는 기존에 호출한 것이 유지되도록 바뀌었다. 이제 더이상 ```_this```를 저장하지 않아도 될것 같다.  
{%codeblock "" lang:javascript%}
var a = "global";

function Person() {
  this.a = "local";
  // 기존의 this 
  setTimeout(function() {
    console.log("1. a is " + this.a); // 1. a is global
  }, 100);
  // this를 저장해서 사용하기
  var _this = this;
  setTimeout(function() {
    console.log("2. a is " + _this.a); // 1. a is local
  }, 100);
  // 새로운 화살표 표현식 내에서의 this
  setTimeout(() => console.log("3. a is " + this.a), 100); // 1. a is local
}
var person = new Person();
{%endcodeblock%}

#### "IIFE(Invoke Immediate Function Express)도 간단해졌다."
괄호로 전체를 묶는 방법은 좀 달라졌으니, 주의 요망
{%codeblock "" lang:javascript%}
// 기존 방법
(function(){
    alert("msg");
}());
// 새로운 방법
(()=>{
    alert("msg");
})();
{%endcodeblock%}


### 9.1.3. 클래스(class) 키워드
새로 추가된 ```class```는 진짜 class이다. ```constructor()```에 생성자를 구현하고, ```extends``` 키워드로 서브클래스를 구현할 수 있으며, ```super``` 키워드를 이용할 수도 있다. 
{%codeblock "" lang:javascript%}
class Car {
  constructor(name) {
    this.name = name;
    this.type = "Car";
  }
  getName() {
    return this.name;
  }
}

class SUV extends Car {
  constructor(name) { // 생성자 함수
    super(name); // super 키워드 이용
    this.type = "SUV";
  }
  getName() { // 함수 오버라이딩
    return super.getName() + " is " + this.type; // super키워드 이용
  }
}

let suv = new SUV("My car");
console.log(suv.getName()); // My car is SUV
{%endcodeblock%}

### 9.1.4. 객체 표현식 기능 확대
좀 더 향상된 방법의 객체 표현식이 만들어졌다.

#### "속성명과 변수명이 같을 때는 한번만 써도 된다."
{%codeblock "" lang:javascript%}
var a = 1,
  b = 2,
  c = 3;

// 기존의 방법
var obj = {
  a: a,
  b: b,
  c: c
};

// 새로운 방법
var obj = {
  a,
  b,
  c
};
console.log(obj); // Object {a=1, b=2, c=3}
{%endcodeblock%}

#### "객체 표현식에 계산식이 들어갈 수 도 있다."
계산식을 이용해서 객체를 선언하고 싶을 때, 기존에는 빈 객체 선언 후 코드로 추가 해야 했지만 그 부분이 개선되었다.  
{%codeblock "" lang:javascript%}
// 기존의 방법
var foo = 1;
var bar = {};
bar["bar" + ++foo] = foo;
bar["bar" + ++foo] = foo;
bar["bar" + ++foo] = foo;
console.log(bar); // Object {bar2=2, bar3=3, bar4=4}

// 새로운 방법
let newBar = {
  ["bar" + ++foo]: foo, ["bar" + ++foo]: foo, ["bar" + ++foo]: foo
}
console.log(newBar); // Object {bar2=2, bar3=3, bar4=4}
{%endcodeblock%}

#### "function 키워드를 생략할 수 있고, getter/setter 정의가 단순해졌다."
{%codeblock "" lang:javascript%}
// function 키워드를 써야 하는 기존의 방법
var obj = {
  func: function() {
    alert("msg");
  }
};
// funciton 키워드를 생략할 수 있는 새로운 방법
var obj = {
  func() {
    alert("msg");
  }
};
// getter, setter를 설정을 위한 기존의 방법
// obj.name에 접근하면 호출되는 함수들이다.
Object.defineProperty(obj, "name", {
  get: function() {
    return this._name;
  },
  set: function(name) {
    this._name = name;
  },
});
// getter, setter를 설정을 위한 새로운 방법
obj = {
  _name: "my name",
  get name() {
    return this._name;
  },
  set name(name) {
    this._name = name;
  }
};
{%endcodeblock%}

### 9.1.5. 템플릿 문자열 표현식
템플릿 문자열 표현식은 ``` ` ```(역따옴표)를 이용한다. 아래의 예제와 같이 더 이상 ```+``` 로 문자열을 연결해서 붙일 필요도 없고, 멀티라인 문자열도 지원한다.  

#### 문자열 템플릿 기본

{%codeblock "" lang:javascript%}
let foo = "bar";

// 템플릿 문자열
console.log(`${foo} ${foo.toUpperCase()}`);

// 멀티라인 지원
console.log(`foo
bar`);
{%endcodeblock%}

#### Tagged template
책에서는 이 용어를 사용하지 않는다. 하지만, [이곳]("http://hacks.mozilla.or.kr/2015/08/es6-in-depth-template-strings-2/")으로 그리고 [MDN]("https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Template_literals#Tagged_template_literals")으로 부터 정식 명칭과 더 명확한 정보를 얻을 수 있었다. 

Tagged template 이란, 템플릿 문자열 앞에 어떤 함수의 이름을 붙이는 것이다. 이렇게 함으로써, 문자열을 가공하는 방법을 제공한다. 이를 활용하여 다국어를 지원, 이스케이핑, 템플릿 언어 등에 응용할 수 있다.

Tag는 함수로 구현하며 다음과 같이 템플릿 문자열 앞에 붙여준다.
{%codeblock "" lang:javascript%}
function myTag (strings, values) {
    return "안녕?"
}
var name = myTag `Hello?`;
console.log(name); // 안녕?
{%endcodeblock%}

### 9.1.6. Destructing
객체를 역으로 여러 개의 변수에 할당하는 것을 의미한다. 좌측값(lvalue)에 ```[]```이나 ```{}```가 있으면 Destructing이라고 보면 된다.

#### "배열을 Destucting 한다."
배열의 값을 순서대로 변수에 할당한다.
{%codeblock "" lang:javascript%}
var myArray = [1, 2, 3, 4, 5];
// 각각의 변수에 myArray의 값들을 할당함. 여기서 3은 버려진다.
var [a, b, , c, d] = myArray;
// swap 예제. lvalue에 쓰인 []은 destructing
[a, b] = [b, a];
{%endcodeblock%}

#### "객체 Destructing 한다."
객체의 value(키 빼고)를 각각의 변수에 할당한다.
{%codeblock "" lang:javascript%}
// 객체의 경우, 객체의 속성명으로 변수로 만든다.
var foo = {
	bar : "I'm bar"
};
var {
  bar
} = foo;
console.log(bar); // I'm bar
{%endcodeblock%}

#### "깊이가 있는 객체를 Destructing 한다."
깊이가 있는 객체의 경우, 객체로 받을 수도, 내부 객체를 풀어서 받을지 표현식으로 결정할 수 있다.
{%codeblock "" lang:javascript%}
var foo = {
  bar: {
    bar1: "I'm bar1",
    bar2: "I'm bar2"
  }
};
var {
  bar,
  bar: {
    bar1,
    bar2
  }
} = foo;
console.log(bar); // Object {bar1: "I'm bar1", bar2: "I'm bar2"}
console.log(bar1); // I'm bar1
console.log(bar2); // I'm bar2
{%endcodeblock%}

#### "Destructing 할 때, 기본 값 지정이 가능하다."
{%codeblock "" lang:javascript%}
var arr = [1, 2];
var [a = 5, b = 6, c = 7, d = 8] = arr;
console.log(a, b, c, d); // 1 2 7 8
{%endcodeblock%}

#### "함수의 파라미터를 받을 때, Destructing 가능하다."
```[]```의 의미에 대해서 조금 헷갈리는 부분이 있는데, 어떤 것이 array이고 어떤 것이 destructing인지 잘 구분해야 한다. 
{%codeblock "" lang:javascript%}
function func([foo,bar]) { // destructing 
	console.log(foo, bar);
  return [bar,foo] // array
}
var [a,b]/* destructing */ = func(["a","b"]);  /* array */
console.log(a, b);
{%endcodeblock%}

### 9.1.7. 함수 인자 기능 확대
당연히 있어야할 것이 지금 나오 느낌.

#### "가변인자 사용이 가능해 졌다."
기존의 방법은 ```arguments```에 ```Array.prototype.slice()```함수를 적용해서 남은 배열을 파라미터를 가져와야 했으나 이제는 ```...``` 붙이면 된다.
{%codeblock "" lang:javascript%}
function func(arg1, ...rest) {
	console.log(arg1, rest);
}
func(1,2,3,4); // 1 [2, 3, 4]
{%endcodeblock%}

반대로, 호출하는 쪽에 ```...```을 붙이면 배열을 펼쳐서 각각의 파라미터로 전달하게 된다.

{%codeblock "" lang:javascript%}
function func(a, b, c, d) {
  console.log(a, b, c, d, );
}
func(...[1, 2, 3, 4]); // 1 2 3 4
{%endcodeblock%}

#### "함수 인자에 기본값 설정이 가능하다."
이전에는 파라미터에 대한 Falsy 체크로 ```param1 = param1 || "default"```을 써야 했지만, 이제는 그러지 않아도 된다. 
{%codeblock "" lang:javascript%}
function func(a = 1, b = 2, c = 3) {
  console.log(a, b, c);
}
func(4, null, undefined);
{%endcodeblock%}

주의할 점은 ```undefined```에 대해서만 기본값을 할당하며, ```null```/```0```/```false```/```""```을 체크하던 기존의 ```param1 = param1 || "default"``` 패턴과는 다르다는 것이다.
### 9.1.8. iterator와 for-of 기능
이 부분은 쉽지 않다. 이해해야 할 것이 좀 있다. ```TODO: 나중에 다시 정리 예정``` 

### 9.1.9. Map과 Set 기능 추가
자바스크립트에는 없었던 유용한 자료구조가 추가되었다. Map과 Set은 각각 필수 함수들을 내장하고 있으며, iterator가 구현되어 있다.

#### "Set과 Map 클래스가 추가되었다."
{%codeblock "" lang:javascript%}
// Map
var map = new Map().set("key1", "value1").set("key2", "value2");
for (let [key, val] of map.entries()) {
  console.log(key, val);
}
// Set
var set = new Set().add("value1").add("value2");
for (let val of set.values()) {
  console.log(val);
}
{%endcodeblock%}

#### "WeakSet과 WeakMap"은 reference가 없어지면 요소가 삭제된다."

{%codeblock "" lang:javascript%}
var obj = {
  data: "foo"
};
var set = new WeakSet().add(obj);
console.log(set.has(obj)); // true
obj = null;
console.log(set.has(obj)); // false
{%endcodeblock%}
 
### 9.1.10. Binary/Octal 표현식 추가
{%codeblock "" lang:javascript%}
console.log(0b11111111); // 255
console.log(0xFF); // 255
{%endcodeblock%}

### 9.1.11. TypedArray 기능 추가
Raw 데이터를 만들고 조작할 수 있는 방법을 제공한다. 웹에서도 socket, video, sound와 같은 데이터를 다루기 시작해면서 필요해 졌다. [MDN]("https://developer.mozilla.org/ko/docs/Web/JavaScript/Typed_arrays") 문서에 친절하게도 한글로 잘 설명되어 있다. 버퍼와 뷰 부분으로 나누어져 있는데, 버퍼에 직접 접근할 수 없고, 뷰를 통해서 접근한다. ```ArrayBuffer()``` 는 버퍼를 위해 사용하고, ```Unint32Array()```와 같은 생성자는 뷰를 생성하기 위해서 사용한다. 
{%codeblock "" lang:javascript%}
var arrayBuffer = new ArrayBuffer(5); // 5바이트 버퍼 생성
var num = new Uint32Array(arrayBuffer, 0, 1);
var ch = new Uint8Array(arrayBuffer, 4, 1);

num[0] = 0xFFFFFFFF;
ch[0] = 0xFF;

console.log(num); // Uint32Array [4294967295]
console.log(ch); // Uint8Array [255]
{%endcodeblock%}

### 9.1.12. 모듈 기능 표준화
Node.js와 CommonJS로 부터 활성화 되기 시작해서 이번 표준에 정의 되었다. ```export```로 각 파일에서 모듈을 정의하고, ```import```로 사용한다. export는 두 가지 종류가 있는데, ```named export```와 ```default export```이다. 

{%codeblock "" lang:javascript%}
// module.js
export function foo() {}
export default bar function() {}

//app.js
import mybar, {foo} from "a.js";
{%endcodeblock%}

```mybar```에는 ```{}```가 필요 없고, ```default export```인 로 설정한 ```bar```가 불려온다. 그 외엔 모두 ```{}``` 안에 넣어야 한다. 나머지 정확한 규칙들은 [MDN]("https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Statements/import") 을 참고하면 된다.    

### 9.1.13. 프락시 모듈
{%codeblock "" lang:javascript%}
var foo = {
  bar: 1
};

// get할 때 속성 존재 여부 체크와 에러 코드를 리턴해주는 Proxy 객체
var fooProxy = new Proxy(foo, {
  get(foo, name) {
    return name in foo ? foo[name] : "ERROR 111: 없엉.";
  }
});

console.log(fooProxy.a); // ERROR 111: 없엉.
console.log(fooProxy.bar); // 1
{%endcodeblock%}

### 9.1.14. Symbol 모듈
이 책은 Symbol에 대한 제대로된 정의와 필요성에 대해서 설명하고 있지 않은데다가 예제 또한 유용하지 않은 것이다. 이에 대해서는 [Hacks Mozillar]("http://hacks.mozilla.or.kr/")에 잘 나와있다. Symbol은 유일한 값을 갖는 속성 키를 만드는데 쓰인다. 만약 내가 라이브러리를 만들어서 html의 특정 엘리멘트에 나만의 속성을 추가했다고 가정한다. 그런 속성명은 다른 라이브러리와 충돌할 수 밖에 없다. 이 때 Symbol()을 사용한다.
{%codeblock "" lang:javascript%}
// 파라미터로 들어가는 값은 주석이다. 디버깅용 출력에 사용된다.
console.log(Symbol("abcd"));

// 매번 생성한 심벌은 다르다.
console.log(Symbol() === Symbol());

// window에 속성으로 등록한다 해도, 변수명이나 함수명에 대한 충돌을 신경쓰지 않아도 된다.
var myFunc = () => {console.log("myFunc")};
var myFuncSym = Symbol("myFunc");

// 등록과 호출
window[myFuncSym] = myFunc;
window[myFuncSym]();
{%endcodeblock%}

### 9.1.15. Promise 모듈
비동기 함수를 Chaining하기 위한 하나의 방식을 제공한다. 

{%codeblock "" lang:javascript%}
// Promise 생성자에는 resolve와 reject를 받는다.
var asyncFunc = new Promise((resolve, reject) => {
  // 여기서 시간이 걸리는 비동기 작업... 예) XMLHttpRequest()
  // 해당 비동기 성공하면 resolve(), 실패하면 reject()이 호출되도록 콜백 구성.
  resolve("success message");
  reject("fail message");
});

asyncFunc
  .then((msg) => { // resolve()에 의해 호출됨.
    console.log("SUCCESS:" + msg);
  })
  .catch((msg) => { // reject()에 의해 호출됨.
    console.log("FAIL:" + msg);
  });
{%endcodeblock%}
