#!/usr/bin/env groovy

import groovy.cli.commons.CliBuilder
import groovy.transform.SourceURI
import java.io.File
import java.nio.file.Path
import java.nio.file.Paths

// Do stuff...
class ThisScript {
  CliLogger log

  void cleanup() {
    cleanup(0)
  }

  void cleanup(int result) {
    System.exit(result)
  }

  void die(String... msg) {
    log.emerg(msg)
    cleanup(1)
  }

  void execute() {
    cleanup()
  }
}

// use log4j if you need more support
class CliLogger {
  File outfile
  boolean useColor = false

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

    LogLevel(String color, boolean isError) {
      this.color = color
      this.isError = isError
    }

    private String color() { return color }
    private String isError() { return isError }
  }

  void mklog(String path) {
    if (path == null || path == "" || path == "/dev/null") {
      return
    }

    this.outfile = new File(path)
    if (!this.outfile.exists()) {
      this.outfile.getParentFile().mkdirs()
      this.outfile.createNewFile()
    }
  }

  void writer(LogLevel level, String[] messages) {
    def color = this.useColor ? level.color() : ""
    def name = level.name().padRight(9)
    def stream = level.isError() ? System.err : System.out

    messages.each { m ->
      def stamp = java.time.OffsetDateTime.now().format(
        java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ssXXX")
      )
      stream.println("${stamp}|${color}${name}\u001B[0m|${m}")
      if (this.outfile != null) {
        this.outfile << "${stamp}|${name}|${m}\n"
      }
    }
  }

  void emerg(String... msg)  { this.writer(LogLevel.EMERGENCY, msg) }
  void alert(String... msg)  { this.writer(LogLevel.ALERT, msg) }
  void crit(String... msg)   { this.writer(LogLevel.CRITICAL, msg) }
  void err(String... msg)    { this.writer(LogLevel.ERROR, msg) }
  void warn(String... msg)   { this.writer(LogLevel.WARNING, msg) }
  void notice(String... msg) { this.writer(LogLevel.NOTICE, msg) }
  void info(String... msg)   { this.writer(LogLevel.INFO, msg) }
  void debug(String... msg)  { this.writer(LogLevel.DEBUG, msg) }
}

@SourceURI
final URI SOURCE_URI

final String SCRIPT_PARENT = Paths.get(SOURCE_URI).getParent().toString()
final String PATH_SEPARATOR = Paths.get(SOURCE_URI).toFile().separator
final String SCRIPT_NAME = Paths.get(SOURCE_URI).getFileName().toString()
final String SCRIPT_BASE = SCRIPT_NAME.take(SCRIPT_NAME.lastIndexOf("."))

// helpers
def logger = new CliLogger()
def defaultLog = "${SCRIPT_PARENT}/logs/${SCRIPT_BASE}/${SCRIPT_BASE}.log"

// CLI Def
def cli = new CliBuilder(
  usage: "${SCRIPT_NAME} [OPTIONS]",
  header: "OPTIONS:"
)

// https://docs.groovy-lang.org/latest/html/gapi/groovy/cli/commons/CliBuilder.html
cli.with {
  h(longOpt: "help", "Show this help message")
  C(longOpt: "cron", "Do not use colored status messages")
  _(
    longOpt: "log",
    args: 1,
    argName: "PATH",
    "Write log to PATH (default: ${defaultLog})"
  )
}

def opts = cli.parse(args)
if (!opts || opts.h) {
  System.out.println("Description\n")
  cli.usage()
  System.exit(opts.h ? 0 : 1)
}

logger.useColor = !opts.C
logger.mklog(opts.log ?: defaultLog)

def thisScript = new ThisScript(
  log: logger
)

thisScript.execute()
