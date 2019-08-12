import Nimble
import RxSwift
import RxTest

func beNextEvent<T>(satisfying: @escaping (T) -> Bool) -> Predicate<Event<T>> {
    return Predicate { expression in
        guard let event = try expression.evaluate() else {
            return .init(
                status: .fail,
                message: .fail("failed evaluating expression"))
        }

        let failingResult = PredicateResult(
            status: .fail,
            message: .expectedCustomValueTo("be next", "\(event)"))

        switch event {
        case .error(_), .completed:
            return failingResult
        case .next(let element):
            return satisfying(element)
                ? .init(status: .matches, message: .expectedTo("expectation fulfilled"))
                : failingResult
        }
    }
}

func beErrorEvent<T>() -> Predicate<Event<T>> {
    return Predicate { expression in
        guard let event = try expression.evaluate() else {
            return .init(
                status: .fail,
                message: .fail("failed evaluating expression"))
        }

        switch event {
        case .next(_), .completed:
            return .init(
                status: .fail,
                message: .expectedCustomValueTo("be error", "\(event)"))
        case .error(_):
            return .init(
                status: .matches,
                message: .expectedTo("expectation fulfilled"))
        }
    }
}

func beCompletedEvent<T>() -> Predicate<Event<T>> {
    return Predicate { expression in
        guard let event = try expression.evaluate() else {
            return .init(
                status: .fail,
                message: .fail("failed evaluating expression"))
        }

        switch event {
        case .next(_), .error(_):
            return .init(
                status: .fail,
                message: .expectedCustomValueTo("be completed", "\(event)"))
        case .completed:
            return .init(
                status: .matches,
                message: .expectedTo("expectation fulfilled"))
        }
    }
}
