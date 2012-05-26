#!/bin/sh
exec scala $0 $*
::!#

// A scala script to unwrap the output of hbase scan.  Assumes that HBase keys contain no spaces.
object M {
  def main(args: Array[String]) {
    if (args.length != 1) {
      println("USAGE: <file to fix>")
      sys.exit(0)
    }
    val newLinePattern = """^ ([^ ]+) +(column=c:.*)$""".r
    val wrappedKeyPattern = """^ ([^ ]+) +$""".r
    val wrappedValuePattern = """^ {2,}(.+)$""".r
    val wrappedKeyAndValuePattern = """^ ([^ ]+) +(.+)$""".r
    var currentKey: String = null
    var currentValue: String = null
    def print = if (currentKey != null) println(" %s %s".format(currentKey, currentValue))
      io.Source.fromFile(args(0)).getLines.foreach { line =>
      newLinePattern.findFirstMatchIn(line) match {
        case Some(m) => {
          print
          currentKey = m.group(1).trim
          currentValue = m.group(2).trim
        }
        case None => wrappedKeyAndValuePattern.findFirstMatchIn(line) match {
          case Some(m) => {
            currentKey += m.group(1).trim
            currentValue += m.group(2).trim
          }
          case None => wrappedKeyPattern.findFirstMatchIn(line) match {
            case Some(m) => currentKey += m.group(1).trim
            case None => wrappedValuePattern.findFirstMatchIn(line) match {
              case Some(m) => currentValue += m.group(1).trim
              case None => System.err.println("MATCHED NOTHING: " + line)
            }
          }
        }
      }
    }
    print
  }
}
