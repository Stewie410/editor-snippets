#!/usr/bin/env groovy

import groovy.cli.commons.CliBuilder
import org.codehaus.groovy.runtime.MethodClosure
import com.sun.tools.javac.main.Option$InvalidValueException


class ClassNameTmpl {
  final String SCRIPT_NAME = org.codehaus.groovy.runtime.StackTraceUtils.deepSanitize(new Exception()).getStackTrace().last().getFileName()
  final String SCRIPT_BASE = SCRIPT_NAME.take(SCRIPT_NAME.lastIndexOf("."))

  private CliLogger log

  static void main(String[] args) {
    parseArgs(args).execute()
  }

  static ClassNameTmpl parseArgs(String[] args) {
    def cli = new CliBuilder(
      usage: "${SCRIPT_NAME} [OPTIONS]",
      header: "OPTIONS:"
    )
    // https://docs.groovy-lang.org/latest/html/gapi/groovy/cli/commons/CliBuilder.html
    cli.with {
      h(longOpt: 'help', 'Show this help message')
      C(longOpt: 'cron', 'Do not use colored status messages')
    }

    def opts = cli.parse(args)
    if (!opts || opts.h) {
      cli.usage()
      System.exit(opts.h ? 0 : 1)
    }

    def inst = new ClassNameTmpl(log: new CliLogger(useColor: !opts.C))
    // inst.log.outfile = new java.io.File("/dev/null")
    // inst.log.mklog()

    return inst
  }

  private void execute() {
    // ...
  }

  private void die(String[] msg) {
    this.log.emerg(msg)
    System.exit(1)
  }
}

// use log4j if you need more support
class CliLogger {
  java.io.File outfile
  boolean useColor

  private def sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss:ZZZ")

  private enum LogLevel {
    EMERGENCY ("\u001B[1;31m", true),
    ALERT     ("\u001B[1;36m", true),
    CRITICAL  ("\u001B[1;33m", true),
    ERROR     ("\u001B[0;31m", true),
    WARNING   ("\u001B[0;33m", false),
    NOTICE    ("\u001B[1;37m", false),
    INFO      ("\u001B[0;32m", false),
    DEBUG     ("\u001B[1;35m", false);

    private final String color
    private final boolean isError
    private final MethodClosure facility

    LogLevel(String color, boolean isError) {
      this.color = color
      this.isError = isError
      this.facility = isError ? System.err::println : System.out::println
    }

    private String color() { return color }
    private String isError() { return error }
    private MethodClosure facility() { return facility }
  }

  void mklog() {
    assert this.outfile != null
    if (!this.outfile.exists()) {
      this.outfile.mkdirs()
      this.outfile.createNewFile()
    }
  }

  void writer(LogLevel level, String[] messages) {
    def color = this.useColor ? level.color() : ""
    def name = level.name().padRight(9)

    messages.each { ->
      def stamp = this.sdf.format(new java.util.Date())
      level.facility << "[${stamp}] [${color}${name}\u001B[0m] ${it}"
      if (this.outfile != null) {
        this.outfile << "[${stamp}] [${name}] ${it}\n"
      }
    }
  }

  void emerg(String[] msg)  { this.writer(LogLevel.EMERGENCY, msg) }
  void alert(String[] msg)  { this.writer(LogLevel.ALERT, msg) }
  void crit(String[] msg)   { this.writer(LogLevel.CRITICAL, msg) }
  void err(String[] msg)    { this.writer(LogLevel.ERROR, msg) }
  void warn(String[] msg)   { this.writer(LogLevel.WARNING, msg) }
  void notice(String[] msg) { this.writer(LogLevel.NOTICE, msg) }
  void info(String[] msg)   { this.writer(LogLevel.INFO, msg) }
  void debug(String[] msg)  { this.writer(LogLevel.DEBUG, msg) }
}
