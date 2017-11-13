var tagsOldToggleFilter = window.toggleFilter;

window.toggleFilter = function(field) {
  tagsOldToggleFilter(field);
  return transform_tags_to_select2(field);
}

function transform_tags_to_select2(field){
  initialized_select2 = $('#tr_' + field + ' .values .select2');
  if (field == 'issue_tags' && initialized_select2.size() == 0) {
    $('#tr_' + field + ' .toggle-multiselect').hide();
    $('#tr_' + field + ' .values .value').attr('multiple', 'multiple');
    $('#tr_' + field + ' .values .value').select2({
      ajax: {
        url: '/auto_completes/redmine_tags',
        dataType: 'json',
        delay: 250,
        data: function (params) {
          return { q: params.term };
        },
        processResults: function (data, params) {
          return { results: data };
        },
        cache: true
      },
      placeholder: ' '
    });
  }
}
