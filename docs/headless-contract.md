# Headless Operation Contract

`MooseNexusHeadlessResult` is the JSON contract for a MooseNexus operation run
without an interactive Pharo UI. A caller executes work through the class-side
`execute:phase:context:do:` boundary, then writes the returned result to its
chosen result file.

The result is schema version `1` and contains:

| Field | Meaning |
| --- | --- |
| `schemaVersion` | Version of this result shape. |
| `operation` | The operation requested by the caller. |
| `phase` | The operation phase in which the result was produced. |
| `status` | `success` or `failure`. |
| `code` | Stable result code: `ok` on success and `operation-failed` for an unclassified failure. |
| `message` | A human-readable failure message, or `null` on success. |
| `context` | Caller-provided, JSON-serializable operational context. Failure results add `errorClass`. |

The boundary catches an `Error` and returns a failure result without serializing
the Pharo stack trace. Callers write that result and must treat `code` as the
stable machine-readable field and `message` as diagnostic text. Future
MooseNexus domain errors may add more specific stable codes without changing
this envelope shape.

For example, a headless build script can record its result before it decides
whether to snapshot the image:

```st
result := MooseNexusHeadlessResult
	          execute: 'build-model'
	          phase: 'execute-spec'
	          context: (Dictionary new
		                    add: 'project' -> 'com.example:demo:1.0.0';
		                    yourself)
	          do: [ spec executeIn: repository ].
result writeTo: 'build-result.json' asFileReference.
```
