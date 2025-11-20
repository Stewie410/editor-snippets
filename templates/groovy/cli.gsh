#!/usr/bin/env groovy

import groovy.cli.commons.CliBuilder

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

    return new ClassNameTmpl(
      log: new CliLogger(!opts.C, "/var/log/${SCRIPT_BASE}/${SCRIPT_BASE}.log")
    )
  }

  private void execute() {
    // ...
  }
}

// use log4j if you need more support
class CliLogger {
  java.io.File outfile
  boolean writeOut = false
  boolean useColor = true
  SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss:ZZZ")

  CliLogger(boolean color, String path) {
    this.useColor = color

    if (path == null || path.isEmpty()) {
      return
    }

    this.outfile = new java.io.File(path)
    this.writeOut = true
    if (!this.outfile.exists()) {
      this.outfile.mkdirs()
      this.outfile.createNewFile()
    }
  }

   void writeOut(String plain, String rgb, boolean stderr, String[] messages) {
    def facility = stderr ? System.err : System.out
    rgb = this.useColor ? rgb : plain
    messages.each { ->
      def stamp = this.sdf.format(new java.util.Date())
      facility.println("[${stamp}] [${rgb.padRight(9)}] ${it}")
      if (this.writeOut) {
        this.outfile << "[${stamp}] [${plain.padRight(9)}] ${it}\n"
      }
    }
  }

  void emerg(String[] messages) {
    writeOut("EMERGENCY", "\u001B[1;31mEMERGENCY\u001B[0m", true, messages)
  }

  void die(String[] messages) {
    emerg(messages)
    System.exit(1)
  }

  void alert(String[] messages) {
    writeOut("ALERT", "\u001B[1;36mALERT\u001B[0m", true, messages)
  }

  void crit(String[] messages) {
    writeOut("CRITICAL", "\u001B[1;33mCRITICAL\u001B[0m", true, messages)
  }

  void err(String[] messages) {
    writeOut("ERROR", "\u001B[0;31mERROR\u001B[0m", true, messages)
  }

  void warn(String[] messages) {
    writeOut("WARNING", "\u001B[0;33mWARNING\u001B[0m", false, messages)
  }

  void notice(String[] messages) {
    writeOut("NOTICE", "\u001B[1;37mNOTICE\u001B[0m", false, messages)
  }

  void info(String[] messages) {
    writeOut("INFO", "\u001B[0;32mINFO\u001B[0m", false, messages)
  }

  void debug(String[] messages) {
    writeOut("DEBUG", "\u001B[1;35mDEBUG\u001B[0m", true, messages)
  }
}
