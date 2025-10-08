//
//  HomeViewReactor.swift
//  SmokingAreaOdi
//
//  Created by 23ji on 10/8/25.
//

import ReactorKit
import RxSwift

final class HomeViewReactor: Reactor {
  enum Action {
  }

  enum Mutation {
  }

  struct State {
  }

  var initialState: State

  init(initialState: State) {
    self.initialState = initialState
  }

  func mutate(action: Action) -> Observable<Mutation> {
    return .empty()
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    return newState
  }
}
