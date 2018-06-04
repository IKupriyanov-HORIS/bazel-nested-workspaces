def nested_third_party_libs():

    native.maven_jar(
        name = "commons_lang3",
        artifact = "org.apache.commons:commons-lang3:3.4",
    )


