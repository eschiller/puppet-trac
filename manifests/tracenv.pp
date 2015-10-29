# == Define: trac::tracenv
#
# Define to handle the creation of a new trac environment. This is the central
# define in the trac module, which most other resources (excepting the trac
# class) are called from.
#
# === Parameters
#
# [*adjust_selinux*]
#   Boolean value. Should be set to true if you'd like the define to
#   automatically fix the file attributes for selinux.
#
# [*apache_group*]
#   The name of group the apache service runs under, used to ensure proper
#   ownership of files the service needs access to.
#
# [*apache_user*]
#   The name of user the apache service runs under, used to ensure proper
#   ownership of files the service needs access to.
#
# [*create_db*]
#   Boolean to determine if a new database should be created for the trac
#   environment. Defaults to true (false is untested).
#
# [*create_repo*]
#   Boolean to determine if a new vcs repo should be created for the trac
#   environment. Defaults to true (false is untested).
#
# [*create_vhost*]
#   Boolean to determine if a new apache vhost should be created for the trac
#   environment. Defaults to true (false is untested).
#
# [*db_file*]
#   The file name of the database that will be created. Defaults to ${name}.db.
#   Only applicable if $db_type is set to 'sqlite'.
#
# [*db_loc*]
#   The file path of the directory hoousing the database that will be created. 
#   Defaults to ${envpath}/db. Only applicable if $db_type is set to 'sqlite'.
#
# [*db_password*]
#   Password for user with read/write to trac environment database. Only
#   applicable for Postgres database types.
#
# [*db_type*]
#   The provider of the database. Currently, 'sqlite' or 'postgres' are valid.
#
# [*db_user*]
#   User with read/write to trac environment database. Only applicable for
#   Postgres database types.
#
# [*envpath*]
#   The root path of the trac environment.
#
# [*redir_http*]
#   Boolean value. Set to true if you want to set up a vhost to redirect all
#   http traffic to https.
#
# [*repo_group*]
#   The group to give file ownership of the repository to.
#
# [*repo_location*]
#   The file path location of the repository. If this is altered from the
#   default, you must ensure that the directory housing the repo is created.
#
# [*repo_type*]
#   The specific version control system being used for the repository.
#   Currently, git and svn are supported.
#
# [*vhost_name*]
#   The fqdn of your named virtualhost. Wildcards with '*' are acceptable.
#   Setting of this parameter is enforced by the trac::tracenv define.
#
# Note: Nearly all of the trac.ini configuration directives can be provided
# by class arguments. For full details, check the documentation at: 
# http://trac.edgewall.org/wiki/TracIni
#
# === Examples
#
# The trac class must be declared first to meet dependencies.
#
# A simple trac environment called 'mytrac' will be created with the following
# declaration. Note that 'vhost_name' is the only parameter that is required by
# the trac::tracenv define.
#
#    trac::tracenv{'mytrac':
#      vhost_name => '*',
#    }
#
# A more complicated trac environment using postgres for the backend db, a Git 
# repository and http to https redirection is as follows:
#
#    trac::db{'mytrac':
#      db_type     => 'postgres',
#      db_user     => 'database_user',
#      db_password => 'PGisGre@t!',
#      repo_type   => 'git',
#    }
#
define trac::tracenv(
  $adjust_selinux                       = $trac::params::adjust_selinux,
  $apache_group                         = $trac::params::apache_group,
  $apache_user                          = $trac::params::apache_user,
  $create_db                            = true,
  $create_repo                          = true,
  $create_vhost                         = true,
  $db_file                              = undef,
  $db_loc                               = undef,
  $db_password                          = undef,
  $db_type                              = 'sqlite',
  $db_user                              = undef,
  $envpath                              = "/trac/${name}",
  $redir_http                           = false,
  $repo_group                           = undef,
  $repo_location                        = undef,
  $repo_type                            = 'svn',
  $vhost_docroot                        = '/var/www',
  $vhost_name                           = undef,
  $attachment_max_size                  = '262144',
  $attachment_max_zip_size              = '2097152',
  $attachment_render_unsafe_content     = false,
  $browser_color_scale                  = true,
  $browser_downloadable_paths           = '/trunk, /branches/*, /tags/*',
  $browser_hide_properties              = 'svk:merge',
  $browser_intermediate_color           = '',
  $browser_intermediate_point           = '',
  $browser_newest_color                 = '(255, 136, 136)',
  $browser_oldest_color                 = '(136, 136, 255)',
  $browser_oneliner_properties          = 'trac:summary',
  $browser_render_unsafe_content        = false,
  $browser_wiki_properties              = 'trac:description',
  $changeset_max_diff_bytes             = '10000000',
  $changeset_max_diff_files             = '0',
  $changeset_wiki_format_messages       = true,
  $header_logo_alt                      = '(please configure the [header_logo] section in trac.ini)',
  $header_logo_link                     = '',
  $logging_custom_log_file              = false,
  $logging_log_level                    = 'DEBUG',
  $logging_log_type                     = 'none',
  $milestone_stats_provider             = 'DefaultTicketGroupStatsProvider',
  $mimeviewer_max_preview_size          = '262144',
  $mimeviewer_mime_map                  = 'text/x-dylan:dylan, text/x-idl:ice, text/x-ada:ads:adb',
  $mimeviewer_mime_map_patterns         = 'text/plain:README|INSTALL|COPYING.*',
  $mimeviewer_tab_width                 = '8',
  $mimeviewer_treat_as_binary           = 'application/octet-stream, application/pdf, application/postscript, application/msword,application/rtf,',
  $notification_admit_domains           = '',
  $notification_always_notify_owner     = false,
  $notification_always_notify_reporter  = false,
  $notification_always_notify_updater   = true,
  $notification_ambiguous_char_width    = 'single',
  $notification_batch_subject_template  = '$prefix Batch modify: $tickets_descr',
  $notification_email_sender            = 'SmtpEmailSender',
  $notification_ignore_domains          = '',
  $notification_mime_encoding           = 'none',
  $notification_sendmail_path           = 'sendmail',
  $notification_smtp_always_bcc         = '',
  $notification_smtp_always_cc          = '',
  $notification_smtp_default_domain     = '',
  $notification_smtp_enabled            = false,
  $notification_smtp_from               = 'trac@localhost',
  $notification_smtp_from_author        = false,
  $notification_smtp_name               = '',
  $notification_smtp_password           = '',
  $notification_smtp_port               = '25',
  $notification_smtp_replyto            = 'trac@localhost',
  $notification_smtp_server             = 'localhost',
  $notification_smtp_subject_prefix     = '__default__',
  $notification_smtp_user               = '',
  $notification_ticket_subject_template = '$prefix #$ticket.id: $summary',
  $notification_use_public_cc           = false,
  $notification_use_short_addr          = false,
  $notification_use_tls                 = false,
  $project_admin                        = '',
  $project_admin_trac_url               = '.',
  $project_descr                        = 'My example project',
  $project_footer                       = 'Visit the Trac open source project at<br /><a href="http://trac.edgewall.org/">http://trac.edgewall.org/</a>',
  $project_icon                         = 'common/trac.ico',
  $project_name                         = 'test',
  $project_url                          = '',
  $query_default_anonymous_query        = 'status!=closed&cc~=$USER',
  $query_default_query                  = 'status!=closed&owner=$USER',
  $query_items_per_page                 = '100',
  $query_ticketlink_query               = '?status=!closed',
  $report_items_per_page                = '100',
  $report_items_per_page_rss            = '0',
  $revisionlog_default_log_limit        = '100',
  $revisionlog_graph_colors             = '[\'#cc0\', \'#0c0\', \'#0cc\', \'#00c\', \'#c0c\', \'#c00\']',
  $roadmap_stats_provider               = 'DefaultTicketGroupStatsProvider',
  $search_min_query_length              = '3',
  $ticket_default_cc                    = '',
  $ticket_default_component             = '',
  $ticket_default_description           = '',
  $ticket_default_keywords              = '',
  $ticket_default_milestone             = '',
  $ticket_default_owner                 = '< default >',
  $ticket_default_priority              = 'major',
  $ticket_default_resolution            = 'fixed',
  $ticket_default_severity              = '',
  $ticket_default_summary               = '',
  $ticket_default_type                  = 'defect',
  $ticket_default_version               = '',
  $ticket_max_comment_size              = '262144',
  $ticket_max_description_size          = '262144',
  $ticket_preserve_newlines             = 'default',
  $ticket_restrict_owner                = false,
  $ticket_workflow                      = 'ConfigurableTicketWorkflow',
  $ticket_workflow_accept               = 'new,assigned,accepted,reopened -> accepted',
  $ticket_workflow_accept_operations    = 'set_owner_to_self',
  $ticket_workflow_accept_permissions   = 'TICKET_MODIFY',
  $ticket_workflow_leave                = '* -> *',
  $ticket_workflow_leave_default        = '1',
  $ticket_workflow_leave_operations     = 'leave_status',
  $ticket_workflow_reassign             = 'new,assigned,accepted,reopened -> assigned',
  $ticket_workflow_reassign_operations  = 'set_owner',
  $ticket_workflow_reassign_permissions = 'TICKET_MODIFY',
  $ticket_workflow_reopen               = 'closed -> reopened',
  $ticket_workflow_reopen_operations    = 'del_resolution',
  $ticket_workflow_reopen_permissions   = 'TICKET_CREATE',
  $ticket_workflow_resolve              = 'new,assigned,accepted,reopened -> closed',
  $ticket_workflow_resolve_operations   = 'set_resolution',
  $ticket_workflow_resolve_permissions  = 'TICKET_MODIFY',
  $timeline_abbreviated_messages        = true,
  $timeline_changeset_collapse_events   = false,
  $timeline_changeset_long_messages     = false,
  $timeline_changeset_show_files        = '0',
  $timeline_default_daysback            = '30',
  $timeline_max_daysback                = '90',
  $timeline_newticket_formatter         = 'oneliner',
  $timeline_ticket_show_details         = false,
  $trac_auth_cookie_lifetime            = '0',
  $trac_auth_cookie_path                = '',
  $trac_authz_file                      = '',
  $trac_authz_module_name               = '',
  $trac_auto_preview_timeout            = '2.0',
  $trac_auto_reload                     = false,
  $trac_backup_dir                      = 'db',
  $trac_base_url                        = '',
  $trac_check_auth_ip                   = false,
  $trac_debug_sql                       = false,
  $trac_default_charset                 = 'utf-8',
  $trac_default_dateinfo_format         = 'relative',
  $trac_genshi_cache_size               = '128',
  $trac_htdocs_location                 = '',
  $trac_ignore_auth_case                = false,
  $trac_jquery_location                 = '',
  $trac_jquery_ui_location              = '',
  $trac_jquery_ui_theme_location        = '',
  $trac_mainnav                         = 'wiki, timeline, roadmap, browser, tickets, newticket, search',
  $trac_metanav                         = 'login, logout, prefs, help, about',
  $trac_mysqldump_path                  = 'mysqldump',
  $trac_never_obfuscate_mailto          = false,
  $trac_permission_policies             = 'DefaultPermissionPolicy, LegacyAttachmentPolicy',
  $trac_permission_store                = 'DefaultPermissionStore',
  $trac_pg_dump_path                    = 'pg_dump',
  $trac_repository_sync_per_request     = '(default)',
  $trac_resizable_textareas            = true,
  $trac_secure_cookies                  = false,
  $trac_show_email_addresses            = false,
  $trac_show_ip_addresses               = false,
  $trac_timeout                         = '20',
  $trac_use_base_url_for_redirect       = false,
  $wiki_ignore_missing_pages            = false,
  $wiki_max_size                        = '262144',
  $wiki_render_unsafe_content           = false,
  $wiki_safe_schemes                    = 'cvs, file, ftp, git, irc, http, https, news, sftp, smb, ssh, svn, svn+ssh',
  $wiki_split_page_names                = false,
  $versioncontrol_allowed_repository_dir_prefixes = '',
) {
  if ! defined(Class['trac']) {
    fail('You must include the trac base class before using any trac defined resources')
  }
  if ! ($vhost_name) {
    fail('You must declare a $vhost_name for each defined tracenv')
  }
  if ($db_type == 'postgres' and ! ($db_user and $db_password)) {
    fail('$db_user and $db_password parameters must be set when using postgres')
  }
  
  # LET'S SET SOME VARIABLES!
  if $db_loc {
    $_db_loc = $db_loc
  } else {
    $_db_loc = "$envpath/db"
  }
  
  if $repo_group {
    $_repo_group = $repo_group
  } else {
    $_repo_group = $name
  }
  
  if $db_file {
    $_db_file = $db_file
  } elsif ($db_type == 'sqlite') {
    $_db_file = "${name}.db"
  } elsif ($db_type == 'postgres') {
    $_db_file = "${name}_db"
  }
  
  $fulldbpath = "$_db_loc/$_db_file"
  
  if ($db_type == 'sqlite') {
    $dburi = "$db_type:$fulldbpath"
  } elsif ($db_type == 'postgres') {
    $dburi = "$db_type://$db_user:$db_password@localhost/$_db_file"
  }
  
  if ($adjust_selinux) {
    $envpath_setype = 'httpd_sys_rw_content_t'
  } else {
    $envpath_setype = undef
  }

  if $repo_location {
    $_repo_location = $repo_location
  } else {
    $repo_dir = "$envpath/repos"
    $_repo_location = "${repo_dir}/$name"
  }
  
  # Create directory for trac files
  file{"$envpath":
    ensure  => 'directory',
    mode    => '644',
    owner   => $apache_user,
    group   => $apache_group,
    seltype => $envpath_setype,
    recurse => true,
    require => Exec["${name}_initenv"],
  }
  
  # Use trac-admin to initialize the trac environment
  exec{"${name}_initenv":
    command   => "mkdir -p $envpath; trac-admin $envpath initenv $name $dburi",
    logoutput => "on_failure",
    path      => ["/usr/local/sbin", "/usr/local/bin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
    creates   => "${envpath}/conf/trac.ini",
    require   => Exec['trac_easy_install'],
    notify    => File[$envpath],
  }
  
  file{"${envpath}/conf/trac.ini":
    ensure  => 'present',
    mode    => '644',
    owner   => $apache_user,
    group   => $apache_group,
    content => template('trac/trac.ini.erb'),
    seltype => $envpath_setype,
    require => Exec["${name}_initenv"],
  }
 
  # Make the header image
  trac::logoimage{"${name}_logo":
    project_name => $name,
    logo_path    => "$envpath/htdocs/${name}_logo.png",
    require      => Exec["${name}_initenv"],
  }
 
  # create apache vhost by calling trac::apache
  if $create_vhost {
    trac::apache{$name:
      apache_user    => $apache_user,
      apache_group   => $apache_group,
      envpath        => $envpath,
      envpath_setype => $envpath_setype,
      vhost_name     => $vhost_name,
      vhost_docroot  => $vhost_docroot,
      redir_http     => $redir_http,
    }
  }
 
  
  # Create db
  if $create_db {
    trac::db{$name:
      adjust_selinux => $adjust_selinux,
      db_user        => $db_user,
      db_password    => $db_password,
      db_type        => $db_type,
      envpath_setype => $envpath_setype,
      fulldbpath     => $fulldbpath,
    }
  }
  
  # create repository  
  if $create_repo {
    trac::repo{$name:
      adjust_selinux => $adjust_selinux,
      envpath        => $envpath,
      envpath_setype => $envpath_setype,
      repo_group     => $_repo_group,
      repo_location  => $repo_location,
      repo_type      => $repo_type,
    }
  }
}
