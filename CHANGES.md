### 0.3.0

  * In addition to gems in the :default group, also preload gems in the group specified in the RACK\_ENV environment variable, or :development if RACK\_ENV is unset.  This is similar to Rails behavior.  (Jonathan Davies)

### 0.2.0

  * Allow polling to be forced on with --force-polling.  If you have mounted the files over NFS, and are editing them remotely, then file system events are not fired, so the reloading doesn't work.  Force it to poll with --force-polling and it will work in this case. (Jamie Cobbett)

### 0.1.0

  * Changes for compatibility with listen 1.0 and later, which it now requires.

### 0.0.3

  * Use optimistic version constraints

### 0.0.2

  * Messages from mr-sparkle now go on stderr, not stdout, just like unicorn's log messages

### 0.0.1

  * Initial release
