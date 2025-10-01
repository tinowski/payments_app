package logger

import (
	"log"
	"os"
)

// Logger provides structured logging
type Logger struct {
	infoLogger  *log.Logger
	errorLogger *log.Logger
	warnLogger  *log.Logger
}

// NewLogger creates a new logger instance
func NewLogger() *Logger {
	return &Logger{
		infoLogger:  log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile),
		errorLogger: log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile),
		warnLogger:  log.New(os.Stdout, "WARN: ", log.Ldate|log.Ltime|log.Lshortfile),
	}
}

// Info logs info level messages
func (l *Logger) Info(v ...interface{}) {
	l.infoLogger.Println(v...)
}

// Error logs error level messages
func (l *Logger) Error(v ...interface{}) {
	l.errorLogger.Println(v...)
}

// Warn logs warning level messages
func (l *Logger) Warn(v ...interface{}) {
	l.warnLogger.Println(v...)
}

// Infof logs formatted info level messages
func (l *Logger) Infof(format string, v ...interface{}) {
	l.infoLogger.Printf(format, v...)
}

// Errorf logs formatted error level messages
func (l *Logger) Errorf(format string, v ...interface{}) {
	l.errorLogger.Printf(format, v...)
}

// Warnf logs formatted warning level messages
func (l *Logger) Warnf(format string, v ...interface{}) {
	l.warnLogger.Printf(format, v...)
}
