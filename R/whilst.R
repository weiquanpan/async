
#' Repeatedly call task, while test returns true
#'
#' @param test Synchronous test function.
#' @param task Asynchronous function to call repeatedly.
#' @param ... Arguments to pass to `task`.
#' @return Deferred value, that is resolved when the iteration is done.
#'
#' @family async control flow
#' @export
#' @examples
#' ## Keep calling while result is bigger than 0.1
#' calls <- 0
#' number <- Inf
#' synchronise(async_whilst(
#'   function() number >= 0.1,
#'   function() {
#'     calls <<- calls + 1
#'     number <<- runif(1)
#'   }
#' ))
#' calls

async_whilst <- function(test, task, ...) {
  force(test)
  task <- async(task)

  self <- deferred$new(
    type = "async_whilst", call = sys.call(),
    action = function(resolve)  {
      if (!test()) {
        resolve(NULL)
      } else {
        task(...)$then(self)
      }
    },
    parent_resolve = function(value, resolve) {
      if  (!test()) {
        resolve(value)
      } else {
        task(...)$then(self)
      }
    }
  )

  self
}

async_whilst <- mark_as_async(async_whilst)
