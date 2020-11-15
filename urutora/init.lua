local modules = (...) and (...):gsub('%.init$', '') .. "." or ""
return require(modules .. 'urutora')
