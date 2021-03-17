let s = React.string
@val external document: {..} = "document"

open Belt

type state = {posts: array<Post.t>, forDeletion: Map.String.t<Js.Global.timeoutId>}

type action =
  | DeleteLater(Post.t, Js.Global.timeoutId)
  | DeleteAbort(Post.t)
  | DeleteNow(Post.t)

module PostItem = {
  @react.component
  let make = (~post, ~dispatch) => {
    let title = post->Post.title
    let author = post->Post.author
    let text = post->Post.text
    let textDivs = text->Belt.Array.map(x => <p className="mb-1 text-sm"> {s(x)} </p>)

    <div
      className="bg-green-700 hover:bg-green-900 text-gray-300 hover:text-gray-100 px-8 py-4 mb-4">
      <h2 className="text-2xl mb-1"> {s(title)} </h2>
      <h3 className="mb-4"> {s(author)} </h3>
      {React.array(textDivs)}
      <button
        className="mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4"
        onClick={_mouseEvt => {
          Js.log("Remo")
          let timeoutId = Js.Global.setTimeout(() => Js.log("Remove"), 10000)
          dispatch(DeleteLater(post, timeoutId))
        }}>
        {s("Remove this post")}
      </button>
    </div>
  }
}

module DeletePost = {
  @react.component
  let make = (~post, ~dispatch, ~timeoutId) => {
    let title = post->Post.title
    let author = post->Post.author

    <div className="relative bg-yellow-100 px-8 py-4 mb-4 h-40">
      <p className="text-center white mb-1">
        {s(`This post from ${title} by ${author} will be permanently removed in 10 seconds.`)}
      </p>
      <div className="flex justify-center">
        <button
          className="mr-4 mt-4 bg-yellow-500 hover:bg-yellow-900 text-white py-2 px-4"
          onClick={_mouseEvt => {
            let _ = Js.Global.clearTimeout(timeoutId)
            dispatch(DeleteAbort(post))
          }}>
          {s("Restore")}
        </button>
        <button
          className="mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4"
          onClick={_mouseEvt => {
            let _ = Js.Global.clearTimeout(timeoutId)
            dispatch(DeleteNow(post))
          }}>
          {s("Delete Immediately")}
        </button>
      </div>
      <div className="bg-red-500 h-2 w-full absolute top-0 left-0 progress" />
    </div>
  }
}

let reducer = (state, action) =>
  switch action {
  | DeleteLater(post, timeoutId) => {
      let del = state.forDeletion->Map.String.set(post->Post.id, timeoutId)
      let state = {...state, forDeletion: del}
      state
    }
  | DeleteAbort(post) => {
      let del = state.forDeletion->Map.String.remove(post->Post.id)
      let state = {...state, forDeletion: del}
      state
    }
  | DeleteNow(post) => state
  }

let initialState = {posts: Post.examples, forDeletion: Map.String.empty}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)

  let divs = state.posts->Belt.Array.map(post => {
    let postId = post->Post.id
    let deleteId = state.forDeletion->Map.String.get(postId)
    let div = switch deleteId {
    | None => <PostItem key={postId} post dispatch />
    | Some(timeoutId) => <DeletePost key={postId} post dispatch timeoutId />
    }
    div
  })

  Js.log(divs)
  <div className="max-w-3xl mx-auto mt-8 relative"> {divs->React.array} </div>
}
