#import "@preview/octique:0.1.1": *
#import "@preview/uniwarn:0.1.1" as uniwarn

#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.has("text") {
    to-string(content.text)
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content.has("child") {
    to-string(content.child)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

#let namespace = "ams-cv"

#uniwarn.register-namespace(namespace)

#let warn = uniwarn.warning.with(
  namespace: namespace,
  prefix: "[" + namespace + "] ",
)

#let default-vars = (
  name: "John Doe",
  title: [Software Developer & DevOps Engineer],
  summary: [#lorem(33)],
  email: "jdoe@mail.com",
  socials: (
    Website: ("https://jdoe.com", [jdoe.com]),
    Email: ("mailto:jdoe@mail.com", [jdoe\@mail.com]),
    Tel: ("tel:+1234567890", [+1234567890]),
    Github: ("https://github.com/jdoe", [\@jdoe]),
  ),
  colors: (
    foreground: rgb("#504945"),
    muted: rgb("#504945").transparentize(85%),
    accent: rgb("#B57614"),
  ),
  font-size: 8pt,
)

#let init-cv(vars: default-vars, body) = {
  set document(
    title: "Curriculum Vitae / Resume",
    author: vars.name + " <" + vars.email + ">",
    keywords: ("cv", "resume"),
    date: datetime.today(),
  )

  set text(
    font: "Space Grotesk",
    fill: vars.colors.foreground,
    size: vars.font-size,
  )

  set page(margin: 24pt)

  show link: it => {
    let size = 0.75em
    [#text(it)#octique-inline(
        color: vars.colors.accent,
        width: size,
        height: size,
        baseline: 0em,
        "link-external",
      )]
  }

  body
}

#let generate-blocks(vars: default-vars) = {
  let section(level: 2, radius: 2pt, body) = block(
    inset: (y: 0.5em),
    outset: (x: 1em),
    above: 1.5em,
    fill: vars.colors.muted,
    width: 100%,
    radius: radius,
    heading(level: level, body),
  )

  let activity(
    right: none,
    level: 3,
    href: none,
    separator: true,
    separator-params: (
      length: 100%,
      stroke: (
        dash: "loosely-dotted",
      ),
    ),
    gutter: 1em,
    body,
  ) = heading(level: level, grid(
    align: horizon,
    gutter: gutter,
    columns: (auto, 1fr, auto),
    if type(href) == type("") { link(href, body) } else { body },
    if separator {
      line(..separator-params)
    } else { none },
    if right != none {
      text(
        fill: vars.colors.foreground.transparentize(30%),
        weight: "thin",
        [#text(fill: white.transparentize(100%), [ |]) #right],
      )
    } else { none },
  ))

  let socials(separator: h(1em)) = (
    vars.socials.pairs().map(((k, (l, v))) => [#k: #link(l, v)]).join(separator)
  )

  let skill(
    hide: false,
    separator: ", ",
    last: none,
    weight: "bold",
    category,
    body,
  ) = {
    if last == none { last = separator }
    let multi = type(body) == array
    let skills = if multi { body } else { (body,) }
    let entry = text.with(weight: weight)
    let content = if multi {
      body.map(skill => entry(skill)).join(separator, last: last)
    } else {
      entry(body)
    }
    [#if not hide { content }#metadata((
        category: category,
        skills: skills,
      ))<skill>]
  }

  let skills(sort: true) = context {
    let skill-dict = (:)
    for skill in query(<skill>) {
      let category = skill.value.category
      if skill-dict.keys().contains(category) {
        let new-skills = skill.value.skills
        let old-skills = skill-dict.at(category)

        let duplicate = new-skills.find(skill => old-skills.contains(skill))
        if (duplicate != none) {
          warn(
            "Found duplicate skill '"
              + to-string(duplicate)
              + "' in '"
              + category
              + "'",
          )
        }

        skill-dict.at(category) += new-skills
      } else {
        skill-dict.insert(skill.value.category, skill.value.skills)
      }
    }

    let skill-list = skill-dict.pairs()
    if sort {
      skill-list = skill-list.sorted(
        key: s => s.last().len(),
        by: (l, r) => l >= r,
      )
    }

    grid(
      columns: (auto, auto),
      align: (right, left),
      gutter: 1em,
      ..skill-list
        .map(((k, v)) => (
          [*#k*: ],
          v
            .dedup()
            .map(skill => box(
              fill: vars.colors.muted,
              inset: (x: 3pt),
              outset: (y: 2pt),
              radius: 2pt,
              skill,
            ))
            .join([, ]),
        ))
        .flatten(),
    )
  }

  let header(profile-image: none, image-radius: 3pt, radius: 3pt) = {
    let with-image = profile-image != none

    let content = [
      // name
      = #block(inset: (bottom: 0.2em), text(size: 1.5em, vars.name))

      // job title
      #text(size: 1.5em, vars.title)\
      #line(length: 100%, stroke: vars.colors.muted)
      #socials()

      #box(heading(level: 2, text(size: vars.font-size)[Summary])) ---
      #vars.summary
    ]

    block(
      fill: vars.colors.muted,
      outset: (x: 1em),
      inset: (y: 1.3em),
      width: 100%,
      radius: radius,
      grid(
        columns: (auto, 1fr),
        gutter: 1em,
        ..if with-image {
          (
            block(radius: image-radius, clip: true, image(
              profile-image.path,
              height: profile-image.height,
            )),
            content,
          )
        } else { (content,) },
      ),
    )
  }

  (
    header: header,
    section: section,
    activity: activity,
    skill: skill,
    skills: skills,
  )
}
