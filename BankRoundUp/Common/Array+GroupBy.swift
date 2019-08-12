extension Array {

    public func groupBy<Key: Hashable>(keySelector: (Element) -> Key) -> [(Key, [Element])] {

        var groupsByKey: [Key: [Element]] = [:]
        var orderedKeys: [Key] = []
        self.forEach { element in
            let key = keySelector(element)
            if let oldGroup = groupsByKey[key] {
                groupsByKey[key] = oldGroup + [element]
            } else {
                orderedKeys.append(key)
                groupsByKey[key] = [element]
            }
        }
        return orderedKeys
            .map { key -> (Key, [Element]) in
                (key, groupsByKey[key]!)
            }
    }
}
