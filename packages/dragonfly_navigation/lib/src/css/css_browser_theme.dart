const css = """
/*
 THe HTML is a custom one
 I don't know if it's a godo idea to store the font size here 
*/
html {
  font-family: "Noto Serif";
  font-size: 16px;
  color: #000000;
  background-color: #ffffff;
}

address {
  display: block;
  font-style: italic;
}

area {
  display: none;
}

article {
  display: block;
}

aside {
  display: block;
}

b {
  font-weight: bold;
}

bdi {
  unicode-bidi: -webkit-isolate;
}

bdo {
  unicode-bidi: bidi-override;
}

blockquote {
  display: block;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 40px;
  margin-right: 40px;
}

body {
  display: block;
  margin: 8px;
}
body:focus {
  outline: none;
}

caption {
  display: table-caption;
  text-align: center;
}

cite {
  font-style: italic;
}

code {
  font-family: monospace;
}

col {
  display: table-column;
}

colgroup {
  display: table-column-group;
}

datalist {
  display: none;
}

dd {
  display: block;
  margin-left: 40px;
}

del {
  text-decoration: line-through;
}

details {
  display: block;
}

dfn {
  font-style: italic;
}

div {
  display: block;
}

dl {
  display: block;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 0;
  margin-right: 0;
}

dt {
  display: block;
}

em {
  font-style: italic;
}

embed:focus {
  outline: none;
}

/* fieldset {
  display: block;
  margin-left: 2px;
  margin-right: 2px;
  padding-top: 0.35em;
  padding-left: 0.75em;
  padding-right: 0.75em;
  padding-bottom: 0.625em;
  border: 2px groove black;
} */

figcaption {
  display: block;
}

figure {
  display: block;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 40px;
  margin-right: 40px;
}

footer {
  display: block;
}

form {
  display: block;
  margin-top: 0em;
}

h1 {
  display: block;
  font-size: 2em;
  margin-top: 0.67em;
  margin-bottom: 0.67em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
}

h2 {
  display: block;
  font-size: 1.5em;
  margin-top: 0.83em;
  margin-bottom: 0.83em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
}

h3 {
  display: block;
  font-size: 1.17em;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
}

h4 {
  display: block;
  margin-top: 1.33em;
  margin-bottom: 1.33em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
}

h5 {
  display: block;
  font-size: 0.83em;
  margin-top: 1.67em;
  margin-bottom: 1.67em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
}

h6 {
  display: block;
  font-size: 0.67em;
  margin-top: 2.33em;
  margin-bottom: 2.33em;
  margin-left: 0;
  margin-right: 0;
  font-weight: bold;
}

head {
  display: none;
}

header {
  display: block;
}

hgroup {
  display: block;
}
/*
hr {
  display: block;
  margin-top: 0.5em;
  margin-bottom: 0.5em;
  margin-left: auto;
  margin-right: auto;
  border-style: inset;
  border-width: 1px;
} */

html {
  display: block;
}

html:focus {
  outline: none;
}

i {
  font-style: italic;
}

iframe:focus {
  outline: none;
}
/* iframe[seamless] {
  display: block;
} */

img {
  display: inline-block;
}
ins {
  text-decoration: underline;
}

kbd {
  font-family: monospace;
}

label {
  cursor: default;
}

legend {
  display: block;
  padding-left: 2px;
  padding-right: 2px;
  border: none;
}

li {
  display: list-item;
  text-align: -webkit-match-parent;
}
link {
  display: none;
}
map {
  display: inline;
}
mark {
  background-color: yellow;
  color: black;
}
menu {
  display: block;
  list-style-type: disc;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 0;
  margin-right: 0;
  padding-left: 40px;
}
nav {
  display: block;
}

object:focus {
  outline: none;
}

ol {
  display: block;
  list-style-type: decimal;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 0;
  margin-right: 0;
  padding-left: 40px;
}

output {
  display: inline;
}
output {
  unicode-bidi: -webkit-isolate;
}
p {
  display: block;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 0;
  margin-right: 0;
}
param {
  display: none;
}

pre {
  display: block;
  font-family: monospace;
  white-space: pre;
  /* margin: 1em 0; */
}

q {
  display: inline;
}
q:before {
  content: open-quote;
}
q:after {
  content: close-quote;
}

rt {
  line-height: normal;
}

s {
  text-decoration: line-through;
}

samp {
  font-family: monospace;
}

script {
  display: none;
}

section {
  display: block;
}
small {
  font-size: smaller;
}

strong {
  font-weight: bold;
}

style {
  display: none;
}

sub {
  vertical-align: sub;
  font-size: smaller;
}

summary {
  display: block;
}

sup {
  vertical-align: super;
  font-size: smaller;
}

table {
  display: table;
  border-collapse: separate;
  border-spacing: 2px;
  border-color: gray;
}

tbody {
  display: table-row-group;
  vertical-align: middle;
  border-color: inherit;
}

td {
  display: table-cell;
  vertical-align: inherit;
}

tfoot {
  display: table-footer-group;
  vertical-align: middle;
  border-color: inherit;
}

th {
  display: table-cell;
  vertical-align: inherit;
}
th {
  font-weight: bold;
  text-align: center;
}

thead {
  display: table-header-group;
  vertical-align: middle;
  border-color: inherit;
}

title {
  display: none;
}

tr {
  display: table-row;
  vertical-align: inherit;
  border-color: inherit;
}

u {
  text-decoration: underline;
}

ul {
  display: block;
  list-style-type: disc;
  margin-top: 1em;
  margin-bottom: 1em;
  margin-left: 0;
  margin-right: 0;
  padding-left: 40px;
}
var {
  font-style: italic;
}
""";
