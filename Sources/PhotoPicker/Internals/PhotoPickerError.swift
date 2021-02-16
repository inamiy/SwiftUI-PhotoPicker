enum PhotoPickerError: Swift.Error
{
    case loadDataFailed(reason: String)
    case underlyingError(Swift.Error)
}
