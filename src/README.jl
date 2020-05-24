function readme(t::Template)
    name = t.pkg_name
    org = t.org
    bors_id = t.bors.id
    return "# $name

$(t.description)

| **Documentation**    | [![dev][docs-dev-img]][docs-dev-url]          |
|----------------------|-----------------------------------------------|
| **Docs Build**       | [![docs build][docs-bld-img]][docs-bld-url]   |
| **Azure Build**      | [![azure][azure-img]][azure-url]              |
| **Code Coverage**    | [![codecov][codecov-img]][codecov-url]        |
| **Bors**             | [![Bors enabled][bors-img]][bors-url]         |

[docs-bld-img]: https://github.com/$(org)/$name/workflows/Documentation/badge.svg
[docs-bld-url]: https://github.com/$(org)/$name/actions?query=workflow%3ADocumentation

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://$(org).github.io/$name/dev/

[azure-img]: https://dev.azure.com/$(org)/$name/_apis/build/status/$(org).$name?branchName=master
[azure-url]: https://dev.azure.com/$(org)/$name/_build/latest?definitionId=1&branchName=master

[codecov-img]: https://codecov.io/gh/$(org)/$name/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/$(org)/$name

[bors-img]: https://bors.tech/images/badge_small.svg
[bors-url]: https://app.bors.tech/repositories/$bors_id

"

end