# peekcodingchallenge

## 3rd Party Tools
The only dependecies I chose were RxSwift and RxCocoa. The main reason being is that I want to showcase my abilities with declaritive programming.

## Architecture
For this challenge, I decided to showcase some of advantages of the MVVM design pattern alongside with RxSwift. For this particular project, I want to highlight that most of the buissness logic is living in the ViewModel layer hidden from the View layer. I was also able to keep the View Model interface quite light, only exposing the properties necessary for the input and outputs. I also found it pretty cool that the accumulator logic for pagination only took a single line.

In the `GithubService`, I also want to highlight wrapping the network calls in the observable world. It makes it quite easy to work with in the ViewModel layer with not much downsides. The `GithubService` is also injected into the ViewModel making it easy to test. In addition, the `GithubService` is done in a way that when the Network layer is refactored, it shouldn't be affected.

In the `API` file, there were many liberties taken in regard to serparation of concerns. Specifically, in the `makeRepoRequest`, there is a lot of coupling between the `URLSession`, JSON Parsing, Error Handling, and Request Building. This is the area that needs the most improvement if I had more time.


## Things to DO
* Refactor the `API` layer and create a generic Network layer that can handle any request
* Create a GQL serialization layer that can help build the GQL queries so no need to hard code
* Write Unit tests for View Model
* Add a Loading Indicator when the Table View scrolls to the bottom
* Add UI to allow user to show `n` amount of entires per request and plugged that into the `first` argument in the repo request 

