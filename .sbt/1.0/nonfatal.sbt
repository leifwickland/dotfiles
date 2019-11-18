// Place the contents of this file in ~/.sbt/1.0/nonfatal.sbt
// Or install by running the following command:
//   curl https://gist.githubusercontent.com/nivekastoreth/7859422d43a8b397f4fb987bed172853/raw/nonfatal.sbt -o ~/.sbt/1.0/nonfatal.sbt

/**
 * This method provides a mechanism for wrapping a given task key for all projects
 * being tracked by the specified State. This means calling this while in a
 * sub-project will still have global level changes applied across all projects
 *
 * This is a fairly heavy hammer and should only be used exceedingly sparingly
 * (i.e. temporarily disabling scalacOptions when debugging)
 *
 * Note: this only works on TaskKey values. Additional logic would have to be written
 *       to allow modification of SettingKey values
 *
 * This logic is based on https://gist.github.com/retronym/e16746e3ef5b554825f6
 * with modifications made to generalize it for any TaskKey
 *
 * @param state   The state being modified (passed in via the Command object
 * @param taskKey The taskKey to modify.
 * @param wrapFn  The function used to modify the value held by the TaskKey
 * @tparam A      The type of value being modified, specified by the TaskKey
 * @return        The new State object with modified TaskKey values
 */
def modifyTaskKey[A](state: State, taskKey: TaskKey[A])(wrapFn: A => A): State = {
  val extracted: Extracted = Project extract state
  import extracted._

  val scopes: Seq[Scope] = Project
    .relation(extracted.structure, actual = true)
    ._1s
    .toSeq
    .filter(_.key == taskKey.key)
    .map(_.scope)
    .distinct

  val redefined: Seq[Setting[Task[A]]] = scopes.map(
    scope => taskKey in scope := wrapFn((taskKey in scope).value)
  )

  BuiltinCommands.reapply(
    extracted.session.appendRaw(redefined),
    structure,
    state
  )
}

def appendTaskSeq[A](setting: TaskKey[Seq[A]])(state: State, args: Seq[A]): State =
  modifyTaskKey(state, setting)(_.filterNot(args.contains) ++ args)

def filterTaskSeq[A](setting: TaskKey[Seq[A]])(state: State, args: Seq[A]): State =
  modifyTaskKey(state, setting)(_.filterNot(args.contains))

def suppressFatalCommand(s: State): State =
  filterTaskSeq(scalacOptions)(s, Seq("-Xfatal-warnings"))

ThisBuild / commands += Command.command("shutup")(suppressFatalCommand)


