This gem is built on top of the i18n library. 
It allows for fetching translations remotely. 
To do so, your app needs to already have the i18n gem.

Add this line below and run bundle. 

```ruby
gem 'i18n_remote', '~> 0.1.1'
```
Add the following lines to configure i18n to use the backend provided by i18n_remote.

```ruby
params = { filenames: ['translation_file_1', 'translation_file_2'], translations_server: 'https://your_translation_server'}

I18n.backend = I18n.backend = I18n::Backend::Chain.new(I18nRemote::Backend::RemoteFile.new(params), I18n.backend)
```


The remote files to be fetched should have the following JSON format

```json
"translation_file_1": {
  "en":
   {
     "name": "Name",
      "title": "Title",
      "content": "Content"
    }
 }
```



 For testing purposes, you can use the params below in your app 
```ruby
  params = { filenames: ['translation_file_1', 'translation_file_2'], translations_server: 'https://my-json-server.typicode.com/royaanane/translations/'}
```
