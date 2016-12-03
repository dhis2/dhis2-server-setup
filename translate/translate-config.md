##Translation server setup

##Structure

###Pootle setup
You should execute all commands as the `pootle` user: 

<pre>
sudo su pootle
</pre>

Activate the Python virtual enviornment. 

<pre>
source /var/www/pootle/env/bin/activate
</pre>

Translation files are stored in the the `/var/www/pootle/env/lib/python2.7/site-packages/pootle/po/` directory. 

###Creating a new POT template from a existing property file
When starting a new project, POT files must be created from the main English properties files. 

<pre>
prop2po -P i18n_app.properties charts.pot
</pre>

###Creating a new PO file from template
This is really just a matter of copying the POT to a PO file, using the ISO language code of the new language. 

This can also be done through the Pootle server by adding a new language to a project. 

<pre>
cp charts.pot sv.po
</pre>

###Updating existing PO files from a property file
Once the template file has been created, PO files should be created for each language


###Syncing Android project strings
<pre>
a2po import --android dhis2-android-sdk/ui-bindings/src/main/res/ --gettext dhis2-android-translations/sdk/
</pre>

###Merging changes to PO files when property files have been changed

When developers make changes to existing property files, these need to be merged with the existing files and data store. 

First, generate a new template with the `prop2po` command. After that, we need to merge the changes into the PO files. 

<pre>
msgmerge -vU strings_useraccount-pt.po strings_useraccount.pot
</pre>

This will merge the existing strings in the `strings_useraccount-pt.po` with the template, deprecating any non-existent strings, and adding any new ones. 

After this the database stores should be updated. 

<pre>
pootle update_stores --project=maintenance-app --language=pt
</pre>

###Syncing database changes

When changes have been made to the translations on the server, they must be flushed to disk. 

<pre>
pootle sync_stores --project=dhis2-android-translations --language=pt
</pre>

This command will update the file stores with what is contained in the database. Options such as `--overwrite` and `--force` may also be needed. 

Once the PO file has been updated, it should be converted to a properties file. 

<pre>
prop2po --duplicates=msgctxt -t i18n_app.properties i18n_app_ar.properties ar.po
</pre>

After this, the SCM can be updated. 

Merge all existing PO files with a new template in a given directory. 
~~~
for f in *.po; do msgmerge -vU $f dhis-web-dashboard-integration.pot ; done
~~~
