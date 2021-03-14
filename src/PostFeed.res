let s = React.string

open Belt

type state = {posts: array<Post.t>, forDeletion: Map.String.t<Js.Global.timeoutId>}

module PostItem = {
  @react.component
  let make = (~post) => {
    let title = post->Post.title
    let author = post->Post.author
    let text = post->Post.text
    // let textDivs = text->Belt.Array.reduce("", (acc, x) =>
    //   `${acc}
    // <p class="mb-1 text-sm">${x}</p>`
    // )
    let textDivs = text->Belt.Array.map(x => <p className="mb-1 text-sm"> {s(x)} </p>)

    <div
      className="bg-green-700 hover:bg-green-900 text-gray-300 hover:text-gray-100 px-8 py-4 mb-4">
      <h2 className="text-2xl mb-1"> {s(title)} </h2>
      <h3 className="mb-4"> {s(author)} </h3>
      {React.array(textDivs)}
      <button className="mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4">
        {s("Remove this post")}
      </button>
    </div>
  }
}

module PostsView = {
  @react.component
  let make = (~posts) => {
    let postItems = posts->Belt.Array.map(post => <PostItem key={post->Post.id} post />)

    <div className="max-w-3xl mx-auto mt-8 relative"> {postItems->React.array} </div>
  }
}

type action =
  | DeleteLater(Post.t, Js.Global.timeoutId)
  | DeleteAbort(Post.t)
  | DeleteNow(Post.t)

let reducer = (state, action) =>
  switch action {
  | DeleteLater(post, timeoutId) => state
  | DeleteAbort(post) => state
  | DeleteNow(post) => state
  }

let initialState = {posts: Post.examples, forDeletion: Map.String.empty}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)

  <PostsView posts=initialState.posts />
}
