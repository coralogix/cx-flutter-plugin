package com.coralogix.flutter.plugin

object ThrowableFactory {
    fun create(message: String, stackTraceString: String): Throwable {
        // Convert the stack trace string to a list of StackTraceElements
        val stackTraceElements = stackTraceString.lines()
            .mapNotNull { parseFlutterStackTraceLine(it) }
            .toTypedArray()

        // Create a Throwable with the provided message
        val throwable = Throwable(message)

        // Set the custom stack trace
        throwable.stackTrace = stackTraceElements

        return throwable
    }

    private fun parseFlutterStackTraceLine(line: String): StackTraceElement? {
        val regex = Regex("""#\d+\s+(.+?)\s+\((.+):(\d+):(\d+)\)""")
        val matchResult = regex.find(line)

        return if (matchResult != null) {
            val (method, filePath, lineNumber, _) = matchResult.destructured

            val (className, methodName) = splitMethodName(method)

            StackTraceElement(
                className,
                methodName,
                filePath,
                lineNumber.toInt()
            )
        } else {
            null
        }
    }

    private fun splitMethodName(method: String): Pair<String, String> {
        val parts = method.split('.')
        return if (parts.size > 1) {
            val className = parts.dropLast(1).joinToString(".")
            val methodName = parts.last()
            Pair(className, methodName)
        } else {
            Pair("", method)
        }
    }
}