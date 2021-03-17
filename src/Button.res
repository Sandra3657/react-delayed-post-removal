let s = React.string

@react.component
let make = (~text, ~className, ~handleClick) =>
  <button className onClick=handleClick> {s(text)} </button>
