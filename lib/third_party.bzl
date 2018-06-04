
def third_party_libs():

    native.maven_jar(
        name = "commons_collections4",
        artifact = "org.apache.commons:commons-collections4:4.1",
    )
