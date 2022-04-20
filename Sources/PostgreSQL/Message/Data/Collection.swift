extension Collection {
    func chunkFromStart(by size: Int) -> [SubSequence] {
        if count <= size {
            return [self[startIndex..<endIndex]]
        }

        let offset = count % size
        var offsetIndex = startIndex
        var chunks = [SubSequence]()

        for _ in stride(from: 0, to: count - offset, by: size) {
            let endIndex = index(offsetIndex, offsetBy: size)
            chunks.append(self[offsetIndex..<endIndex])
            offsetIndex = endIndex
        }

        chunks.append(self[offsetIndex..<endIndex])

        return chunks
    }

    func chunkFromEnd(by size: Int) -> [SubSequence] {
        if count <= size {
            return [self[startIndex..<endIndex]]
        }

        let offset = count % size
        var offsetIndex: Self.Index
        var chunks = [SubSequence]()

        if offset > 0 {
            offsetIndex = index(startIndex, offsetBy: offset)
            chunks.append(self[startIndex..<offsetIndex])
        } else {
            offsetIndex = startIndex
        }

        for _ in stride(from: offset, to: count, by: size) {
            let endIndex = index(offsetIndex, offsetBy: size)
            chunks.append(self[offsetIndex..<endIndex])
            offsetIndex = endIndex
        }

        return chunks
    }
}
